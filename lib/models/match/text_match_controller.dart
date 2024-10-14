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

    // Debug: Print the populated lists (optional for debugging)
    print('Label Name List: $labelNameList');
    print('Product Name List: $productNameList');
    print('Product Class List: $productClassList');
  }

  // Function to match a list of texts against product data
  void matchTextList(List<String> textList) {
    matchedData.value = ''; // Clear previous matches

    // Lowercase all input texts and remove empty/whitespace-only strings
    List<String> lowerCaseTexts = textList
        .map((text) => text.toLowerCase().trim())
        .where((text) => text.isNotEmpty) // Filter out empty texts
        .toList();

    print('Matching texts: $lowerCaseTexts');

    // If no valid text to match, exit early
    if (lowerCaseTexts.isEmpty) {
      print('No valid text to match.');
      return;
    }

    updateProductLists(); // Update product lists

    // Iterate over each input text and attempt to find a match
    for (String lowerCaseText in lowerCaseTexts) {
      if (_matchSingleText(lowerCaseText)) {
        return; // Exit if a match is found
      }
    }

    // If no matches were found for any text in the list
    print('No matches found for any of the texts.');
  }

  // Helper function to match a single text against product data
  bool _matchSingleText(String text) {
    // Check for exact or partial match in labelNameList
    for (String label in labelNameList) {
      if (_isPartialMatch(text, label)) {
        matchedData.value = label; // Exact or substring match
        print('Matched label: $label');
        return true; // Exit if a match is found
      }
    }

    // Check for word-by-word matches in productNameList and productClassList
    bool productNameMatch =
        _matchInList(text, productNameList, 'Product Name List');
    if (!productNameMatch) {
      bool productClassMatch =
          _matchInList(text, productClassList, 'Product Class List');
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
    List<String> words = text.split(RegExp(r'\s+')); // Split text into words

    for (String word in words) {
      if (_isPartialMatch(word, list.join(" "))) {
        // Allow partial match in the entire list
        matchedData.value = word; // Store the match
        print('Matched in $listName: $word');
        return true; // Exit if a match is found
      }
    }
    return false; // No match found in this list
  }

  // Helper function to check for partial matches (substring matching)
  bool _isPartialMatch(String text, String label) {
    return text.contains(label) || label.contains(text); // Allow both ways
  }
}
