import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_shop/models/other/next_page.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/Controller/count.dart';
import 'package:smart_shop/ui/cart.dart';
import 'package:smart_shop/ui/favourite.dart';
import 'package:smart_shop/ui/home/home.dart';
import 'package:smart_shop/ui/login_screen.dart';
import 'package:smart_shop/ui/profile.dart';

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  _BottomNavControllerState createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController>
    with SingleTickerProviderStateMixin {
  final _pages = [
    Home(),
    const Cart(),
    const Favourite(),
    const Profile(),
  ];

  int _currentIndex = 0;
  late AnimationController _animationController;

  // Simulate login status (replace with actual authentication logic)
  final bool isLoggedIn = true;

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
    final countController = Get.put(CountProduct());

    return isLoggedIn
        ? Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white),
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
                  MaterialPageRoute(builder: (context) => const NextPage()),
                );
              },
              backgroundColor: AppColors.deep_blue,
              foregroundColor: Colors.white,
              elevation: 10,
              child: const Icon(Iconsax.scan),
            ),
            bottomNavigationBar: BottomAppBar(
              notchMargin: 8.0,
              shape: const CircularNotchedRectangle(),
              color: AppColors.deep_blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.home, "Home", 0),
                  _buildCartNavItem(countController),
                  const SizedBox(width: 48), // Space for FAB
                  _buildFavoriteNavItem(countController),
                  _buildBottomNavItem(Iconsax.user, "Profile", 3),
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
            body: LoginScreen(),
          );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

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

  Widget _buildCartNavItem(CountProduct countController) {
    return Obx(() {
      final int cartCount = countController.cartProductscount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBottomNavItem(Icons.shopping_cart, "Shop", 1),
          if (cartCount > 0)
            Positioned(
              top: -4,
              right: 23,
              child: _buildBadge(cartCount),
            ),
        ],
      );
    });
  }

  Widget _buildFavoriteNavItem(CountProduct countController) {
    return Obx(() {
      final int favoriteCount = countController.favoriteProductscount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBottomNavItem(Icons.favorite, "Favorite", 2),
          if (favoriteCount > 0)
            Positioned(
              top: -4,
              right: 30,
              child: _buildBadge(favoriteCount),
            ),
        ],
      );
    });
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
