import 'package:get/get.dart';
import 'package:smart_shop/models/other/next_page_controller.dart';

class TextMatchController extends GetxController {
  var matchedData = ''.obs; // Observable string for matched data

  // Using sets for faster lookups
  final Set<String> labelNameSet = {};
  final Set<String> productNameSet = {};
  final Set<String> productClassSet = {};

  // Function to update product sets
  void updateProductLists() {
    final productController = Get.find<ProductController>();

    labelNameSet.clear();
    productNameSet.clear();
    productClassSet.clear();

    for (var product in productController.products) {
      if (product['label'] != null) {
        labelNameSet.add(product['label'].toLowerCase());
      }
      if (product['product-name'] != null) {
        productNameSet.add(product['product-name'].toLowerCase());
      }
      if (product['product'] != null) {
        productClassSet.add(product['product'].toLowerCase());
      }
    }

    // Debug: Print the populated sets (optional for debugging)
    print('Label Name Set: $labelNameSet');
    print('Product Name Set: $productNameSet');
    print('Product Class Set: $productClassSet');
  }

  // Function to match a list of texts against product data
  void matchTextList(List<String> textList) {
    matchedData.value = ''; // Clear previous matches

    // Lowercase all input texts and remove empty/whitespace-only strings
    List<String> lowerCaseTexts = textList
        .map((text) => text.toLowerCase().trim())
        .where((text) => text.isNotEmpty)
        .toList();

    print('Matching texts: $lowerCaseTexts');

    if (lowerCaseTexts.isEmpty) {
      print('No valid text to match.');
      return;
    }

    updateProductLists(); // Update product lists

    // Iterate over each input text and attempt to find a match
    for (String text in lowerCaseTexts) {
      if (_matchSingleText(text)) {
        return; // Stop if a match is found
      }
    }

    print('No matches found for any of the texts.');
  }

  // Function to match a single text against product data
  bool _matchSingleText(String text) {
    // Check for an **exact** match first in labelNameSet, productNameSet, and productClassSet
    if (_exactMatchInSet(text, labelNameSet, 'Label')) return true;
    if (_exactMatchInSet(text, productNameSet, 'Product Name')) return true;
    if (_exactMatchInSet(text, productClassSet, 'Product Class')) return true;

    // If no exact match, fall back to partial match
    if (_partialMatchInSet(text, labelNameSet, 'Label')) return true;
    if (_partialMatchInSet(text, productNameSet, 'Product Name')) return true;
    if (_partialMatchInSet(text, productClassSet, 'Product Class')) return true;

    return false; // No match found
  }

  // Function to match text exactly in a set
  bool _exactMatchInSet(String text, Set<String> dataSet, String setName) {
    if (dataSet.contains(text)) {
      matchedData.value = text; // Store the exact match
      print('Exact match in $setName: $text');
      return true;
    }
    return false;
  }

  // Function to match text partially in a set
  bool _partialMatchInSet(String text, Set<String> dataSet, String setName) {
    for (String data in dataSet) {
      if (_isPartialMatch(text, data)) {
        matchedData.value = data; // Store the partial match
        print('Partial match in $setName: $data');
        return true; // Exit if a partial match is found
      }
    }
    return false;
  }

  // Helper function to check for partial matches (substring matching)
  // Modify to only allow reasonable matches (e.g., longer than 3 characters)
  bool _isPartialMatch(String text, String label) {
    if (text.length > 3 && label.length > 3) {
      return text.contains(label) || label.contains(text); // Allow both ways
    }
    return false;
  }
}
