import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        imagePath.value = image.path;
        detectImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> detectImage(File image) async {
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

    Get.off(() => SearchScreen(
          searchText: textdata.toString(),
        ));
  }
}
