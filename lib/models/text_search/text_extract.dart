import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_shop/models/text_search/text_extract_controller.dart';

class TextExtractionPage extends StatelessWidget {
  final TextExtractionController controller = Get.put(TextExtractionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Extraction from Image'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 200),
                ElevatedButton(
                  onPressed: () => controller.detectImage(ImageSource.gallery),
                  child: const Text('Gallery Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.detectImage(ImageSource.camera),
                  child: const Text('Camera Image'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
