import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_shop/common/full_screen_loaders.dart';
import 'package:smart_shop/common/loaders.dart';
import 'package:http/http.dart' as http;
import 'package:smart_shop/ui/search_screen.dart';

class ObjectSearchController extends GetxController {
  static ObjectSearchController get instance => Get.find();
  final ImagePicker _picker = ImagePicker();
  final RxString imagePath = ''.obs; // Path of the selected image
  final RxString apidata = ''.obs; // API data response
  final RxString apiResponse = ''.obs; // To store the API response
  final RxBool loading = false.obs; // Loading state
  final RxString userInput = ''.obs; // User input text
  final RxString matchedData = ''.obs; // Observable string for matched data

  @override
  void onInit() {
    super.onInit();
    userInput.value =
        "Only write object name. I have the following classes: 'Bag', 'Book', 'Bottle', 'Burka', 'Calculator', 'Chair', 'Coat', 'Daster', 'Earphone', 'Furniture', 'Gaming Console', 'Gardening Tools', 'Keyboard', 'Kids Toy', 'Laptop', 'Mobile', 'Monitor', 'Mouse', 'Notebook', 'Panjabi', 'Pant', 'Pen', 'Pendrive', 'Saree', 'Shirt', 'Shoe', 'Three Piece', 'Tie', 'T-Shirt', 'Wall Clock', 'Watch'. Don't write everything; only write the object name.";
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        imagePath.value = image.path;
        TFullScreenLoader.openLoadingDialog(
            "Searching......", 'assets/animation/docer_animation.json');
        await submitImageAndText(); // Ensure this is awaited
      } else {
        TLoaders.warningSnackBar(
            title: "No Image Selected", message: "Please select an image.");
      }
    } catch (e) {
      print('Error picking image: $e');
      TLoaders.errorSnackBar(
          title: "Image Pick Failed",
          message: "An error occurred while picking the image.");
    }
  }

  Future<void> submitImageAndText() async {
    loading.value = true; // Set loading to true

    if (imagePath.value.isEmpty) {
      TLoaders.warningSnackBar(
          title: "No Image", message: "Please pick an image first.");
      loading.value = false; // Ensure loading is reset
      return;
    }

    if (userInput.value.isEmpty) {
      TLoaders.warningSnackBar(
          title: "No Input", message: "Please enter some text.");
      // loading.value = false; // Ensure loading is reset
      return;
    }

    try {
      final File imageFile = File(imagePath.value);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://mediumslateblue-toad-458609.hostingersite.com/api_image.php?image'),
      );

      request.fields['user_message'] = userInput.value; // Add the user's input
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        apiResponse.value = responseData; // Save the response to a string
        print('API Response: $responseData');
        final Map<String, dynamic> parsedResponse = jsonDecode(responseData);
        final String data = parsedResponse['choices'][0]['message']['content'];
        apidata.value = data;
        print('API Response: $data');
        matchData();
      } else {
        String errorMsg =
            "Failed to submit data. Status Code: ${response.statusCode}";
        if (response.statusCode == 401) {
          errorMsg = "Unauthorized access. Please check your credentials.";
        } else if (response.statusCode == 500) {
          errorMsg = "Server error. Please try again later.";
        }
        TLoaders.errorSnackBar(title: "API Error", message: errorMsg);
      }
    } catch (e) {
      print('Error submitting data: $e');
      TLoaders.errorSnackBar(
          title: "Submission Failed",
          message: "An error occurred while submitting the data.");
    } finally {
      print('Submission complete.');
      // loading.value = false; // Set loading to false
      // TFullScreenLoader.stopLoading(); // Stop loading dialog
    }
  }

  void matchData() {
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
    ].map((item) => item.toLowerCase()).toList(); // Convert to lowercase

    matchText(apidata.value,
        dataToMatch); // Call matchText with API data and dataToMatch

    // Log matched data for debugging
    print("Matched data found: ${matchedData.value}");
    TFullScreenLoader.stopLoading(); // Stop loading dialog

    // Navigate to SearchScreen after a successful match
    if (matchedData.value.isNotEmpty) {
      Get.off(() => SearchScreen(
          searchText: matchedData.value)); // Navigate to SearchScreen
    } else {
      TLoaders.warningSnackBar(
          title: "No Product Found", message: "Please try again.");
    }
  }

  void matchText(String text, List<String> dataToMatch) {
    final Set<String> matches = {}; // Create a Set to avoid duplicates
    final List<String> words =
        text.toLowerCase().split(RegExp(r'\s+')); // Split text into words

    for (final String word in words) {
      if (dataToMatch.contains(word)) {
        matches.add(word); // Add matched word to the set
      }
    }

    // Join the matched words into a single string
    matchedData.value = matches.join(', ');
  }
}
