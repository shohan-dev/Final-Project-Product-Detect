import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smart_shop/ui/product_details_screen.dart';

Widget fetchData(String collectionName, {bool iscart = false}) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection(collectionName)
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Text("Something went wrong"),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: iscart
              ? const Text("No cart items added yet!")
              : const Text("No favorites added yet!"),
        );
      }

      int productCount = snapshot.data!.docs.length;

      return Scaffold(
        appBar: AppBar(
          title:
              iscart ? const Text("Cart Items") : const Text("Favorite Items"),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text(
                          "Are you sure you want to remove all items?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text("Delete"),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (confirm) {
                  // Get the current user's email
                  final userEmail = FirebaseAuth.instance.currentUser!.email;

                  // Fetch all documents in the collection
                  final collectionRef = FirebaseFirestore.instance
                      .collection(collectionName)
                      .doc(userEmail)
                      .collection("items");

                  final querySnapshot = await collectionRef.get();

                  // Delete all documents
                  for (var doc in querySnapshot.docs) {
                    await doc.reference.delete();
                  }

                  // Optional: Show a confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "All items have been removed from the collection!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: productCount,
                itemBuilder: (_, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshot.data!.docs[index];

                  var images = documentSnapshot['images'];
                  if (images is List && images.isNotEmpty) {
                    images = images[0];
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 30,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey[50],
                          radius: 40,
                          backgroundImage: images != null && images is String
                              ? NetworkImage(images)
                              : const NetworkImage(
                                  "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png"),
                        ),
                        title: Text(
                          documentSnapshot['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "৳ ${documentSnapshot['price']}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                        trailing: GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            child: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () {
                            FirebaseFirestore.instance
                                .collection(collectionName)
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .collection("items")
                                .doc(documentSnapshot.id)
                                .delete();
                          },
                        ),
                        onTap: () {
                          // Navigate to ProductDetails page and pass the product data
                          // Replacing the entire stack with ProductDetails
                          Get.to(() => ProductDetails({
                                'product-name': documentSnapshot['name'],
                                'product-price': documentSnapshot['price'],
                                'product-img': documentSnapshot['images'],
                                'product-description':
                                    documentSnapshot['decresption'],
                              }));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
