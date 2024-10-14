import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String searchText;

  const SearchScreen({super.key, this.searchText = ""});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String inputText = "";
  List<QueryDocumentSnapshot> allProducts = [];
  List<QueryDocumentSnapshot> displayedProducts = [];
  Timer? _debounce;
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    inputText = widget.searchText;
    _fetchAllProducts();
  }

  Future<void> _fetchAllProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    final snapshot =
        await FirebaseFirestore.instance.collection("products").get();
    setState(() {
      allProducts = snapshot.docs;
      displayedProducts = _searchProducts(inputText);
      isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      isSearching = true;
    });

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        inputText = query;
        displayedProducts = _searchProducts(query);
        isSearching = false;
      });
    });
  }

  List<QueryDocumentSnapshot> _searchProducts(String query) {
    if (query.isEmpty) {
      return allProducts
          .take(10)
          .toList(); // Return the first 10 products if no query
    }

    return allProducts.where((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      // Convert fields to lowercase to ensure case-insensitive search
      String productName =
          (data['product-name'] as String?)?.toLowerCase() ?? '';
      String product = (data['product'] as String?)?.toLowerCase() ?? '';
      String label = (data['label'] as String?)?.toLowerCase() ?? '';

      // Check if any of the fields contain the query
      return productName.contains(query.toLowerCase()) ||
          product.contains(query.toLowerCase()) ||
          label.contains(query.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Search your product",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.deep_blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    onChanged: _onSearchChanged,
                    initialValue: inputText,
                    decoration: InputDecoration(
                      hintText: "Your product name . . .",
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.deep_blue),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Builder(
                  builder: (BuildContext context) {
                    if (isLoading || isSearching) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (displayedProducts.isEmpty && inputText.isNotEmpty) {
                      return const Center(
                        child: Text("No products found",
                            style: TextStyle(fontSize: 18)),
                      );
                    }

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
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
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => ProductDetails(data));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: CachedNetworkImage(
                                      imageUrl: data["product-img"][0] ?? '',
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 8.0),
                                    child: Center(
                                      child: Text(
                                        data["product-name"] ??
                                            'Unknown Product',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Price: ${data["product-price"]?.toString() ?? 'N/A'} ৳",
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
