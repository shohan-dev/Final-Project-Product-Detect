import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_shop/models/match/text_match_controller.dart';
import 'package:smart_shop/ui/search_screen.dart';

class TextExtractionController extends GetxController {
  var extractedText = ''.obs;
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

        // Call matchText from MatchTextController
        matchTextController.matchText(extractedText.value);
        final textdata = matchTextController.matchedData;

        Get.off(() => SearchScreen(
              searchText: textdata.toString(),
            ));
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
      matchTextController.matchText(
          recognizedText.text); // Call matchText from MatchTextController
    } catch (e) {
      print("Error extracting text: $e");
    } finally {
      textRecognizer.close();
    }
  }
}
