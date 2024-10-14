import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_shop/models/object_search/object_search_controller.dart';
import 'package:smart_shop/models/other/next_page_controller.dart';
import 'package:smart_shop/models/text_search/text_extract_controller.dart';
import 'package:smart_shop/ui/AppColors.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX Controller instance
    final ProductController productController = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
          title: const Text('Smart Shop',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor:
              AppColors.splash_colors // Updated color for better contrast
          ),
      body: Center(
        child: Obx(() {
          if (productController.isLoading.value) {
            return const CircularProgressIndicator(); // Loading spinner
          }

          return SingleChildScrollView(
            // Scroll support for smaller screens
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Consistent padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100), // Reduced unnecessary height
                  _buildSearchButton(context, 'Text Search',
                      _showImageSourceBottomSheet, AppColors.splash_colors),
                  const SizedBox(height: 20),
                  _buildSearchButton(
                      context,
                      'Object Search',
                      _showImageSourceBottomSheetObject,
                      AppColors.splash_colors),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Reusable button builder with modern styling
  Widget _buildSearchButton(
      BuildContext context, String label, Function onPressed, Color color) {
    return ElevatedButton(
      onPressed: () => onPressed(context, label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Button background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded edges
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 120, vertical: 15), // Consistent button size
        elevation: 5, // Button elevation for better UX
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // Bottom sheet for Text Search
  void _showImageSourceBottomSheet(BuildContext context, String text) {
    final TextExtractionController controller =
        Get.put(TextExtractionController());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _buildBottomSheetContent(context, text, controller.detectImage);
      },
    );
  }

  // Bottom sheet for Object Search
  void _showImageSourceBottomSheetObject(BuildContext context, String text) {
    final ObjectSearchController controller = Get.put(ObjectSearchController());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _buildBottomSheetContent(context, text, controller.pickImage);
      },
    );
  }

  // Reusable bottom sheet content for both search options
  Widget _buildBottomSheetContent(
      BuildContext context, String text, Function(ImageSource) onSelect) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.camera_alt,
                color: AppColors.splash_colors), // Color icon to match theme
            title: const Text('Camera', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              onSelect(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo,
                color: AppColors.splash_colors), // Color icon to match theme
            title: const Text('Gallery', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              onSelect(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
