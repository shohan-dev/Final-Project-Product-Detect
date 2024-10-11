import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ml_image/models/object_search/object_search_controller.dart';

class ObjectSearch extends StatelessWidget {
  final ObjectSearchController controller = Get.put(ObjectSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter TFlite'),
      ),
      body: Center(
        child: Obx(() {
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
                Text('No image selected'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.pickImage(ImageSource.camera),
                    child: Text('Camera'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => controller.pickImage(ImageSource.gallery),
                    child: Text('Gallery'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Label: ${controller.label}'),
              Text('Confidence: ${controller.confidence}'),
            ],
          );
        }),
      ),
    );
  }
}
