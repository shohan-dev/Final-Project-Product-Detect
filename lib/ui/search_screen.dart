import 'dart:async';
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
  bool isLoading = true; // Track loading state for initial fetch
  bool isSearching = false; // Track loading state for search

  @override
  void initState() {
    super.initState();
    inputText = widget.searchText; // Initialize inputText with searchText
    _fetchAllProducts();
  }

  Future<void> _fetchAllProducts() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    final snapshot =
        await FirebaseFirestore.instance.collection("products").get();
    setState(() {
      allProducts = snapshot.docs;
      displayedProducts = _searchProducts(inputText); // Perform initial search
      isLoading = false; // Set loading to false after data is fetched
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      isSearching = true; // Show loading indicator when search starts
    });

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        inputText = query;
        displayedProducts = _searchProducts(query);
        isSearching = false; // Hide loading indicator after search is done
      });
    });
  }

  List<QueryDocumentSnapshot> _searchProducts(String query) {
    if (query.isEmpty) {
      return allProducts
          .take(10)
          .toList(); // Show first 10 products if search is empty
    }

    return allProducts.where((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String productName = data['product-name'].toLowerCase();
      String product = data['product'].toLowerCase();
      return productName.contains(query.toLowerCase()) ||
          product.contains(query.toLowerCase());
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
        title: const Text("Search your product by Text"),
        automaticallyImplyLeading: false,
        backgroundColor: SecondaryColors.secondary_colors,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextFormField(
                onChanged: _onSearchChanged,
                initialValue: inputText, // Set initial value from inputText
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
              const SizedBox(height: 20),
              Expanded(
                child: Builder(
                  builder: (BuildContext context) {
                    if (isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (isSearching) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (displayedProducts.isEmpty && inputText.isNotEmpty) {
                      return const Center(
                        child: Text(
                          "No products found",
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return ListView(
                      children:
                          displayedProducts.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 5.0),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => ProductDetails(data));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 6,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(data['product-img'][0]),
                                ),
                                title: Text(
                                  data['product-name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  "৳ ${data['product-price']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
