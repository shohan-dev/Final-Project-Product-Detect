import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_shop/models/other/next_page.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/cart.dart';
import 'package:smart_shop/ui/favourite.dart';
import 'package:smart_shop/ui/home.dart';
import 'package:smart_shop/ui/profile.dart';

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  _BottomNavControllerState createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController>
    with SingleTickerProviderStateMixin {
  final _pages = [
    const Home(),
    const Favourite(),
    const Cart(),
    const Profile(),
  ];

  var _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Smooth animation duration
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              "Smart Shop",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.deep_blue,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NextPage(),
            ),
          );
        },
        backgroundColor: AppColors.deep_blue,
        foregroundColor: Colors.white,
        elevation: 10,
        child: const Icon(Iconsax.scan),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10.0,
        shape: const CircularNotchedRectangle(),
        color: AppColors.deep_blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildBottomNavItem(Icons.home, "Home", 0),
            ),
            Expanded(
              child: _buildBottomNavItem(Icons.shopping_cart, "Shop", 1),
            ),
            const SizedBox(width: 48), // Space for the FAB
            Expanded(
              child: _buildBottomNavItem(Icons.favorite, "Favorite", 2),
            ),
            Expanded(
              child: _buildBottomNavItem(Iconsax.user, "Profile", 3),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _pages[_currentIndex],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

    // The entire container is now clickable, but not the icon or text separately
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _animationController.forward(from: 0.0);
        });
      },
      child: Container(
        height: 50, // Adjust the height for a larger clickable area
        color: Colors.transparent, // Transparent background for container

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center icon and text
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 28, // Adjust icon size
            ),
            const SizedBox(height: 4), // Spacing between icon and text
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12, // Adjust font size
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
