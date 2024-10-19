import 'package:get/get.dart';

class ObjectMatchController extends GetxController {
  static ObjectMatchController instance = Get.find(); // Singleton instance
  var matchedData = ''.obs; // Observable string for matched data



  // Define your list of data to match against in lowercase
  final List<String> dataToMatch = [
    'Bag',
    'Book',
    'Bottle',
    'Burka',
    'Calculator',
    'Chair',
    'Coat',
    'Daster',
    'Earphone',
    'Furniture',
    'Gaming Console',
    'Gardening Tools',
    'Keyboard',
    'Kids Toy',
    'Laptop',
    'Mobile',
    'Monitor',
    'Mouse',
    'Notebook',
    'Panjabi',
    'Pant',
    'Pen',
    'Pendrive',
    'Saree',
    'Shirt',
    'Shoe',
    'Three Piece',
    'Tie',
    'T-Shirt',
    'Wall Clock',
    'Watch',
    // Add more items as needed
  ].map((item) => item.toLowerCase()).toList(); // Convert to lowercase

  void matchText(String text) {
    matchedData.value = ''; // Clear previous matches
    List<String> words = text.toLowerCase().split(
        RegExp(r'\s+')); // Convert text to lowercase and split into words

    // Create a Set to avoid duplicates
    Set<String> matches = {};


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