import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'next_page.dart'; // Make sure this path is correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter TFlite',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter TFlite'),
        ),
        body: const NextPage(),
      ),
    );
  }
}
