
import 'package:flutter/material.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/cart.dart';
import 'package:smart_shop/ui/favourite.dart';
import 'package:smart_shop/ui/home.dart';
import 'package:smart_shop/ui/profile.dart';
import 'package:smart_shop/ui/login_screen.dart';

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  _BottomNavControllerState createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  final _pages = [
    const Home(),
    const Favourite(),
    const Cart(),
    const Profile(),
  ];

  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),  // Set the height to a smaller value like 50
        child: AppBar(
          backgroundColor: SplashColors.splash_colors,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart,
                color: Color(0xffD65B08),
                size: 45,
              ),
              SizedBox(width: 12),
              Text(
                "Smart Shop",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        selectedItemColor: AppColors.deep_blue,
        unselectedItemColor: Colors.grey[600],
        currentIndex: _currentIndex,
        selectedLabelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: "Favourite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: "Login",
          ),
        ],
        onTap: (index) {
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
      body: _currentIndex < 4 ? _pages[_currentIndex] : Container(),
    );
  }
}
