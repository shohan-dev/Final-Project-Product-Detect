import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_shop/common/loaders.dart';
import 'package:smart_shop/models/match/object_match_controller.dart';
import 'package:smart_shop/ui/search_screen.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ObjectSearchController extends GetxController {
  static ObjectSearchController get instance => Get.find();
  final ImagePicker _picker = ImagePicker();
  var imagePath = ''.obs;
  var recognitions = [].obs;
  var label = ''.obs;
  var confidence = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadModel();
  }

  // Load the TFLite model
  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
    } catch (e) {
      print('Error loading model: $e');
      TLoaders.errorSnackBar(
          title: "Model Load Failed", message: "Unable to load the model.");
    }
  }

  // Pick an image from the specified source (camera or gallery)
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        imagePath.value = image.path;
        await detectImage(File(image.path));
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

  // Run the model on the selected image
  Future<void> detectImage(File image) async {
    try {
      recognitions.value = await Tflite.runModelOnImage(
            path: image.path,
            numResults: 6,
            threshold: 0.05,
            imageMean: 127.5,
            imageStd: 127.5,
          ) ??
          [];

      if (recognitions.isNotEmpty) {
        label.value = recognitions[0]['label'].toString();
        confidence.value = recognitions[0]['confidence'].toString();
      }

      // Call matchText from ObjectMatchController
      final controller = Get.put(ObjectMatchController());
      controller.matchText(label.value);
      final textdata = controller.matchedData;

      print('Label: ${label.value}');
      print('Confidence: ${confidence.value}');

      if (double.parse(confidence.value) > 0.99) {
        Get.off(() => SearchScreen(searchText: textdata.toString()));
      } else {
        TLoaders.warningSnackBar(title: "No Match Found", message: "Try Again");
      }

      //   if (double.parse(confidence.value) > 0.99) {
      //     if (label.value == 'Daster' || label.value == 'Pen') {
      //       Get.off(() => SearchScreen(searchText: textdata.toString()));
      //     } else if (confidence.value == '1.0') {
      //       Get.off(() => SearchScreen(searchText: textdata.toString()));
      //     } else {
      //       TLoaders.warningSnackBar(
      //           title: "No Match Found", message: "Try Again");
      //     }
      //   } else {
      //     TLoaders.warningSnackBar(title: "No Match Found", message: "Try Again");
      //   }
      // } catch (e) {
      //   print('Error detecting image: $e');
      //   TLoaders.errorSnackBar(
      //       title: "Detection Failed", message: "Unable to process the image.");
      // }
    } catch (e) {
      print('Error detecting image: $e');
      TLoaders.errorSnackBar(
          title: "Detection Failed", message: "Unable to process the image.");
    }
  }
}
