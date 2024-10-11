import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_shop/models/match/object_match_controller.dart';
import 'package:smart_shop/models/object_search/object_search_controller.dart';

class ObjectSearch extends StatelessWidget {
  final ObjectSearchController controller = Get.put(ObjectSearchController());
  final matchtextcontroller = Get.put(ObjectMatchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter TFlite'),
      ),
      body: Center(
        child: Obx(() {
          // Recalculate match text dynamically based on the current label
          matchtextcontroller.matchText(controller.label.value);
          var data = matchtextcontroller.matchedData;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (controller.imagePath.value.isNotEmpty)
                Image.file(
                  File(controller.imagePath.value),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                )
              else
                const Text('No image selected'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 20),
              Text('Label: ${controller.label.value}'), // Use .value
              Text('Confidence: ${controller.confidence.value}'), // Use .value
              const SizedBox(height: 20),
              Text('Detected Objects: $data'), // Update dynamically
            ],
          );
        }),
      ),
    );
  }
}
