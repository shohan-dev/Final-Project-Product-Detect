import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_shop/models/other/next_page.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/cart.dart';
import 'package:smart_shop/ui/favourite.dart';
import 'package:smart_shop/ui/home.dart';
import 'package:smart_shop/ui/login_screen.dart'; // Ensure this import is correct
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

  // Simulate login status (replace with actual authentication logic)
  bool isLoggedIn = true; // Change this to reflect actual login status

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? Scaffold(
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
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
          )
        : const Scaffold(
            body: LoginScreen(), // Only show the login page if not logged in
          );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _animationController.forward(from: 0.0);
        });
      },
      child: Container(
        height: 50,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
