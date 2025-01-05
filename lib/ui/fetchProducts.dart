import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

      // final cartcontroller = Get.put(CountProduct());

      // cartcontroller.cartProductscount.value = productCount;

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: productCount,
              itemBuilder: (_, index) {
                DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];

                var images = documentSnapshot['images'];
                if (images is List && images.isNotEmpty) {
                  images = images[0];
                }

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                            : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
