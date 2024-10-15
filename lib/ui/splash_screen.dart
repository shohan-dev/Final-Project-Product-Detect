import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/bottom_nav_controller.dart';
import 'package:smart_shop/ui/login_screen.dart'; // Import your login screen
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  // Method to check Firebase Auth user login status
  void _checkUserLoginStatus() {
    Timer(
      const Duration(seconds: 2),
          () {
        User? user = FirebaseAuth.instance.currentUser;

        // If the user is logged in, go to the BottomNavController (home screen)
        if (user != null) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (_) => const BottomNavController()),
          );
        } else {
          // If the user is not logged in, navigate to the Login screen
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashColors.splash_colors,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon.png',
                    height: 150.h,
                    width: 150.w,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "My Smart Shop",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 40.sp,
                    ),
                  ),
                  SizedBox(height: 100.h),
                  const CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: AppColors.deep_blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
