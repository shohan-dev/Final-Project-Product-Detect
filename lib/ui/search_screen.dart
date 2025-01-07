import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String searchText;

  const SearchScreen({super.key, this.searchText = ""});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _voiceInput = "";
  List<QueryDocumentSnapshot> allProducts = [];
  List<QueryDocumentSnapshot> displayedProducts = [];
  Timer? _debounce;
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchText;
    _fetchAllProducts();
  }

  Future<void> _fetchAllProducts() async {
    try {
      setState(() => isLoading = true);
      final snapshot =
          await FirebaseFirestore.instance.collection("products").get();
      setState(() {
        allProducts = snapshot.docs;
        displayedProducts = _searchProducts(_searchController.text);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching products: $e");
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() => isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        displayedProducts = _searchProducts(query);
        isSearching = false;
      });
    });
  }

  List<QueryDocumentSnapshot> _searchProducts(String query) {
    // if (query.isEmpty) {
    //   // Shuffle the list of products and take the first 20 products
    //   List<QueryDocumentSnapshot> randomProducts = List.from(allProducts)
    //     ..shuffle();
    //   return randomProducts.take(20).toList();
    // }
    if (query.isEmpty) return allProducts.take(20).toList();

    return allProducts.where((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String productName =
          (data['product-name'] as String?)?.toLowerCase() ?? '';
      String product = (data['product'] as String?)?.toLowerCase() ?? '';
      String label = (data['label'] as String?)?.toLowerCase() ?? '';
      return productName.contains(query.toLowerCase()) ||
          product.contains(query.toLowerCase()) ||
          label.contains(query.toLowerCase());
    }).toList();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech Status: $status"),
      onError: (error) => print("Speech Error: $error"),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _voiceInput = result.recognizedWords;
          _searchController.text = _voiceInput;
          _onSearchChanged(_voiceInput);
        });
      });

      // Automatically stop listening after speech input is done (e.g., after 5 seconds of silence).
      Future.delayed(const Duration(seconds: 5), () {
        if (_isListening) {
          _stopListening();
        }
      });
    } else {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Search Products",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.deep_blue,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        _isListening ? Colors.redAccent : AppColors.deep_blue,
                    child: IconButton(
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic,
                          color: Colors.white),
                      onPressed:
                          _isListening ? _stopListening : _startListening,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading || isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (displayedProducts.isEmpty &&
                      _searchController.text.isNotEmpty) {
                    return const Center(
                        child: Text("No products found",
                            style: TextStyle(fontSize: 18)));
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = displayedProducts[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () => Get.to(() => ProductDetails(data)),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            elevation: 5,
                            child: Column(
                              children: [
                                Expanded(
                                  child: CachedNetworkImage(
                                    imageUrl: data["product-img"]?[0] ?? '',
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                      data["product-name"] ?? 'Unknown Product',
                                      style: const TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center),
                                ),
                                Text(
                                    "Price: ${data["product-price"]?.toString() ?? 'N/A'} ৳",
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: _isListening,
        child: AnimatedOpacity(
          opacity: _isListening ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0, left: 20.0),
              child: AvatarGlow(
                glowColor: AppColors.splash_colors,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                animate: _isListening,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.splash_colors,
                  child: IconButton(
                      icon:
                          const Icon(Icons.mic, size: 50, color: Colors.white),
                      onPressed: _stopListening),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
