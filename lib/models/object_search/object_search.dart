import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_shop/models/object_search/object_search_controller.dart';

class ObjectSearch extends StatelessWidget {
  ObjectSearch({Key? key, required this.product}) : super(key: key);
  final ObjectSearchController controller = Get.put(ObjectSearchController());
  final List<Map<String, dynamic>> product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter TFlite'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => controller.pickImage(ImageSource.camera),
              child: const Text('Camera'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => controller.pickImage(ImageSource.gallery),
              child: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
