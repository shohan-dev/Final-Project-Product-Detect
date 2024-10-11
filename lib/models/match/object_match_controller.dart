import 'package:get/get.dart';
import 'package:smart_shop/models/object_search/object_search_controller.dart';

class ObjectMatchController extends GetxController {
  static ObjectMatchController instance = Get.find(); // Singleton instance
  var matchedData = ''.obs; // Observable string for matched data

  // Access a single label string from ObjectSearchController
  final RxString labelData = ObjectSearchController.instance.label;

  // Define your list of data to match against in lowercase
  final List<String> dataToMatch = [
    "example",
    "important",
    "keyword",
    "another",
    "book",
    "mY",
    "magpie",
    // Add more items as needed
  ].map((item) => item.toLowerCase()).toList(); // Convert to lowercase

  void matchText(String text) {
    matchedData.value = ''; // Clear previous matches
    List<String> words = text.toLowerCase().split(
        RegExp(r'\s+')); // Convert text to lowercase and split into words

    // Create a Set to avoid duplicates
    Set<String> matches = {};

    // Check if the labelData matches any item in dataToMatch
    if (dataToMatch.contains(labelData.value.toLowerCase())) {
      matches.add(labelData.value.toLowerCase()); // Add the matched labelData
    }

    // Check if any of the words match with dataToMatch
    for (String word in words) {
      if (dataToMatch.contains(word)) {
        matches.add(word); // Add matched word to the set
      }
    }

    // Join the matched words into a single string
    matchedData.value =
        matches.join(', '); // Store matched data as a single string
  }
}
