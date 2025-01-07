import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/ui/bottom_nav_controller.dart';
import 'package:smart_shop/ui/fetchProducts.dart';

class Favourite extends StatefulWidget {
  const Favourite({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
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
          child: fetchData("users-favourite-items"),
        ),
      ),
    );
  }
}
