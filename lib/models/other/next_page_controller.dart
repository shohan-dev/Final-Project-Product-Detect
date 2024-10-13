import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  // Store product data in an observable list
  var products = <Map<String, dynamic>>[].obs;

  // Loading state for UI
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDataProduct();
  }

  // Fetch data from Firestore
  Future<void> fetchDataProduct() async {
    try {
      isLoading(true); // Show loading indicator

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();

      // Map Firestore document to product details (fields)
      List<Map<String, dynamic>> productList = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>; // Extract fields as a Map
      }).toList();

      // Update the products observable list
      products.assignAll(productList);

    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading(false); // Hide loading indicator
    }
  }
}
