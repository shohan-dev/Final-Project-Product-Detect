import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/bottom_nav_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2),()=>Navigator.push(context, CupertinoPageRoute(builder: (_)=>const BottomNavController())));
    super.initState();
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

                  SizedBox(
                    height: 10.h,
                  ),

                  Text(
                    "My Smart Shop",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 40.sp,
                    ),
                  ),

                  SizedBox(
                    height: 100.h,
                  ),

                  const CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Color(0xFFF8934D),
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