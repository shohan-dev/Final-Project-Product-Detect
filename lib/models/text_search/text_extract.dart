import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/models/text_search/text_extract_controller.dart';


class TextExtractionPage extends StatelessWidget {
  final TextExtractionController controller =
      Get.put(TextExtractionController());

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
                // Show the image selected from gallery or camera
                Obx(() {
                  return controller.image.value != null
                      ? Image.file(
                          controller.image.value!,
                          height: 300,
                          width: 250,
                          fit: BoxFit.cover,
                        )
                      : const Text(
                          'No image selected',
                          style: TextStyle(fontSize: 18),
                        );
                }),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.pickImageGallery,
                  child: const Text('Gallery Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.pickImageCamera,
                  child: const Text('Camera Image'),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return controller.extractedText.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            controller.extractedText.value,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : const Text(
                          'No text extracted yet.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        );
                }),
                const SizedBox(height: 20),
                Obx(() {
                  return controller.matchTextController.matchedData.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Matched Words:',
                                style: TextStyle(fontSize: 18),
                              ),
                              ...controller.matchTextController.matchedData
                                  .map((item) => Text(item)),
                            ],
                          ),
                        )
                      : const Text(
                          'No matches found.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
