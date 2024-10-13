import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/models/object_search/object_search.dart';
import 'package:smart_shop/models/text_search/text_extract.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    // create a funciton about avg
    fetchdataproduct();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 300),
            ElevatedButton(
              onPressed: () {
                Get.off(() => TextExtractionPage());
              },
              child: const Text('Text search'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.off(() => ObjectSearch());
              },
              child: const Text('Object search'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchdataproduct() async {
    // Fetch data from Firestore
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await _firestore.collection('products').get();

    // Use a Set to ensure uniqueness
    Set<String> uniqueProducts = {};

    // Map through the documents and extract only the product names
    for (var doc in querySnapshot.docs) {
      if (doc['product'] != null) {
        uniqueProducts.add(doc['product']);
      }
    }

    // Convert the Set back to a List if needed
    List<String> products = uniqueProducts.toList();

    // Print the unique products
    print("Unique Products: $products");
    print("Total unique products: ${products.length}");
  }
}
