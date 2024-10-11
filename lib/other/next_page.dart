import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/models/object_search/object_search.dart';
import 'package:smart_shop/models/text_search/text_extract.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 300),
            ElevatedButton(
              onPressed: () {
                Get.to(() => TextExtractionPage());
              },
              child: const Text('Text search'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(() => ObjectSearch());
              },
              child: const Text('Object search'),
            ),
          ],
        ),
      ),
    );
  }
}
