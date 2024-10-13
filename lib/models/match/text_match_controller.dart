import 'package:get/get.dart';
import 'package:smart_shop/models/other/next_page_controller.dart';

class TextMatchController extends GetxController {
  var matchedData = ''.obs; // Observable string for matched data

  final List<String> labelNameList = [];
  final List<String> productNameList = [];
  final List<String> productClassList = [];

  // Function to update product lists
  void updateProductLists() {
    // Initialize ProductController only once
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

  void matchText(String text) {
    matchedData.value = ''; // Clear previous match
    String lowerCaseText = text.toLowerCase().trim(); // Trim and lowercase the input text

    // If the extracted text is empty, show a snackbar using GetX
    if (lowerCaseText.isEmpty) {
      _showSnackBar('No text found. Please take another photo or select an image.');
      return;
    }

    print('Matching text: $lowerCaseText');

    updateProductLists(); // Update product lists

    // Check for closest substring match in labelNameList
    String? bestMatch;
    int bestMatchLength = 0;

    for (String label in labelNameList) {
      if (label.contains(lowerCaseText)) {
        matchedData.value = label; // Exact or substring match
        print('Matched full/substring label: $label');
        _showSnackBar('Match found: $label');
        return;
      }

      // Check for partial word matches or best phrase match
      int matchLength = _findBestPartialMatch(lowerCaseText, label);
      if (matchLength > bestMatchLength) {
        bestMatch = label;
        bestMatchLength = matchLength;
      }
    }

    // If a best partial match was found
    if (bestMatch != null) {
      matchedData.value = bestMatch;
      print('Best partial match: $bestMatch');
      _showSnackBar('Best partial match: $bestMatch');
      return;
    }

    // Check for word-by-word matches in productNameList and productClassList
    bool productNameMatch = _matchInList(lowerCaseText, productNameList, 'productNameList');
    if (!productNameMatch) {
      bool productClassMatch = _matchInList(lowerCaseText, productClassList, 'productClassList');
      if (!productClassMatch) {
        // If no matches found
        print('No matches found.');
        _showSnackBar('No match found. Please take another photo.');
      }
    }
  }

  // Helper to find the length of best partial match
  int _findBestPartialMatch(String input, String target) {
    List<String> inputWords = input.split(RegExp(r'\s+'));
    List<String> targetWords = target.split(RegExp(r'\s+'));

    int matchLength = 0;
    for (String word in inputWords) {
      if (targetWords.contains(word)) {
        matchLength += word.length;
      }
    }
    return matchLength;
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
