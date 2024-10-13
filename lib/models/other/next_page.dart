import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/models/object_search/object_search.dart';
import 'package:smart_shop/models/other/next_page_controller.dart';
import 'package:smart_shop/models/text_search/text_extract.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX Controller instance
    final ProductController productController = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: Center(
        child: Obx(() {
          // Show a loading spinner while data is loading
          if (productController.isLoading.value) {
            return const CircularProgressIndicator();
          }

          // Once data is loaded, display the content and provide navigation options
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 300),
              ElevatedButton(
                onPressed: () {
                  // Navigate to TextExtractionPage and pass the product data
                  Get.off(() => TextExtractionPage(product: productController.products));
                },
                child: const Text('Text search'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to ObjectSearch and pass the product data
                  Get.off(() => ObjectSearch(product: productController.products));
                },
                child: const Text('Object search'),
              ),
              const SizedBox(height: 20),
            ],
          );
        }),
      ),
    );
  }
}
