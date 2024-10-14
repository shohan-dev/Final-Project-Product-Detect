import 'package:get/get.dart';
import 'package:smart_shop/models/other/next_page_controller.dart';

class TextMatchController extends GetxController {
  var matchedData = ''.obs; // Observable string for matched data

  final List<String> labelNameList = [];
  final List<String> productNameList = [];
  final List<String> productClassList = [];

  // Function to update product lists
  void updateProductLists() {
    final productController = Get.find<ProductController>();

    labelNameList.clear();
    productNameList.clear();
    productClassList.clear();

    for (var product in productController.products) {
      if (product['label'] != null) {
        labelNameList.add(product['label'].toLowerCase());
      }
      if (product['product-name'] != null) {
        productNameList.add(product['product-name'].toLowerCase());
      }
      if (product['product'] != null) {
        productClassList.add(product['product'].toLowerCase());
      }
    }

    // Debug: Print the populated lists
    print('Label Name List: $labelNameList');
    print('Product Name List: $productNameList');
    print('Product Class List: $productClassList');
  }

  // Function to match a list of texts against product data
  void matchTextList(List<String> textList) {
    matchedData.value = ''; // Clear previous matches

    if (textList.isEmpty) {
      _showSnackBar('No texts found. Please take another photo or select an image.');
      return;
    }

    // Lowercase all input texts
    List<String> lowerCaseTexts = textList.map((text) => text.toLowerCase().trim()).toList();

    print('Matching texts: $lowerCaseTexts');

    updateProductLists(); // Update product lists

    // Iterate over each input text and attempt to find a match
    for (String lowerCaseText in lowerCaseTexts) {
      // Check for empty text
      if (lowerCaseText.isEmpty) {
        _showSnackBar('Empty text found. Please check the input or take another photo.');
        continue; // Skip empty texts
      }

      // Try to match the current text against the product data
      if (_matchSingleText(lowerCaseText)) {
        return; // Exit if a match is found
      }
    }

    // If no matches were found for any text in the list
    print('No matches found for any of the texts.');
    _showSnackBar('No match found for any of the texts. Please take another photo.');
  }

  // Helper function to match a single text against product data
  bool _matchSingleText(String text) {
    // Check for exact or substring match in labelNameList
    for (String label in labelNameList) {
      if (label.contains(text)) {
        matchedData.value = label; // Exact or substring match
        print('Matched label: $label');
        _showSnackBar('Match found: $label');
        return true; // Exit if a match is found
      }
    }

    // Check for word-by-word matches in productNameList and productClassList
    bool productNameMatch = _matchInList(text, productNameList, 'Product Name List');
    if (!productNameMatch) {
      bool productClassMatch = _matchInList(text, productClassList, 'Product Class List');
      if (productClassMatch) {
        return true;
      }
    } else {
      return true;
    }

    // No match for the current text
    return false;
  }

  // Helper to match individual words in a list
  bool _matchInList(String text, List<String> list, String listName) {
    List<String> words = text.split(RegExp(r'\s+'));

    for (String word in words) {
      if (list.contains(word)) {
        matchedData.value = word; // Store the match
        print('Matched in $listName: $word');
        _showSnackBar('Match found in $listName: $word');
        return true; // Exit if a match is found
      }
    }
    return false; // No match found in this list
  }

  // Snackbar function using GetX to display messages to the user
  void _showSnackBar(String message) {
    Get.snackbar(
      'Info', // Title of the snackbar
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }
}
