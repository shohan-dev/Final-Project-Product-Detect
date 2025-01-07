import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/ui/bottom_nav_controller.dart';
import 'package:smart_shop/ui/fetchProducts.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const BottomNavController());
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: fetchData("users-cart-items", iscart: true),
        ),
      ),
    );
  }
}
