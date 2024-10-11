import 'package:get/get.dart';

class TextMatchController extends GetxController {
  var matchedData = <String>[].obs; // Observable list for matched data

  // Define your list of data to match against in lowercase
  final List<String> dataToMatch = [
    "example",
    "important",
    "publisher",
    "keyword",
    "another",
    "book",
    "mY",
    "cover"
    // Add more items as needed
  ].map((item) => item.toLowerCase()).toList(); // Convert to lowercase

  // Define a priority list (higher index means lower priority)
  final List<String> priorityList = [
    "important",
    "publisher",
    "keyword",
    "cover"

    // Add more prioritized items as needed
  ].map((item) => item.toLowerCase()).toList();

  void matchText(String text) {
    matchedData.clear(); // Clear previous matches
    List<String> words =
        text.toLowerCase().split(RegExp(r'\s+')); // Split text into words

    // Create a set to track matched words
    Set<String> matchedWords = {};

    for (String word in words) {
      if (dataToMatch.contains(word)) {
        matchedWords.add(word); // Add matched word to the set
      }
    }

    // Sort matched words by priority
    var sortedMatchedWords = matchedWords.toList()
      ..sort((a, b) {
        int aIndex = priorityList.indexOf(a);
        int bIndex = priorityList.indexOf(b);
        if (aIndex == -1)
          aIndex =
              priorityList.length; // If not found, assign the lowest priority
        if (bIndex == -1) bIndex = priorityList.length;
        return aIndex.compareTo(bIndex);
      });

    matchedData
        .addAll(sortedMatchedWords); // Add sorted words to the observable list
  }
}
