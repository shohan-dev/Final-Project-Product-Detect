import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_shop/models/match/text_match_controller.dart';
import 'package:smart_shop/ui/search_screen.dart';

class TextExtractionController extends GetxController {
  var extractedText = ''.obs; // Observable for extracted text
  var image = Rxn<File>(); // Observable for the image
  final ImagePicker _picker = ImagePicker();
  final TextMatchController matchTextController =
      Get.put(TextMatchController());

  Future<void> detectImage(ImageSource img) async {
    try {
      final pickedFile = await _picker.pickImage(source: img);
      if (pickedFile != null) {
        image.value = File(pickedFile.path);
        await extractText(image.value!);

        print(
            "This is extract data======================== $extractedText.value");

        // Call matchText from MatchTextController
        matchTextController.matchTextList(extractedText.value.split('\n'));
        final textdata = matchTextController.matchedData;

        print("this is text data send $textdata");

        // Ensure textdata is not null or empty
        if (textdata.isNotEmpty) {
          Get.off(() => SearchScreen(
                searchText: textdata.toString(),
              ));
        } else {
          print("No matched data found.");
        }
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image from gallery: $e");
    }
  }

  Future<void> extractText(File imageFile) async {
    final InputImage inputImage = InputImage.fromFile(imageFile);
    final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      extractedText.value = recognizedText.text;

      // Ensure extracted text is not null or empty
      if (extractedText.value.isNotEmpty) {
        matchTextController.matchTextList(recognizedText.text
            .split('\n')); // Call matchText from MatchTextController
      } else {
        print("Extracted text is empty.");
      }
    } catch (e) {
      print("Error extracting text: $e");
    } finally {
      textRecognizer.close();
    }
  }
}
