import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CountProduct extends GetxController {
  static CountProduct get instance => Get.find();

  var favoriteProductscount = 0.obs;
  var cartProductscount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToFavoriteProducts();
    _listenToCartProducts();
  }

  void _listenToFavoriteProducts() {
    FirebaseFirestore.instance
        .collection("users-favourite-items")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      favoriteProductscount.value = snapshot.docs.length;
    }, onError: (e) {
      print("Error listening to favorite products: $e");
    });
  }

  void _listenToCartProducts() {
    FirebaseFirestore.instance
        .collection("users-cart-items")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      cartProductscount.value = snapshot.docs.length;
    }, onError: (e) {
      print("Error listening to cart products: $e");
    });
  }
}
