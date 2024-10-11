import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
      model: "assets/mobilenet_v1_1.0_224.tflite",
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
    int startTime = DateTime.now().millisecondsSinceEpoch;
    recognitions.value = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    ) ?? [];

    if (recognitions.isNotEmpty) {
      label.value = recognitions[0]['label'].toString();
      confidence.value = recognitions[0]['confidence'].toString();
    }

    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }
}
