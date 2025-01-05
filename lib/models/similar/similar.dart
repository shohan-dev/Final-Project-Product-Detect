import 'dart:convert'; // For JSON decoding
import 'dart:typed_data'; // For handling image bytes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:smart_shop/models/similar/widgets/product_grid_view.dart';
import 'package:smart_shop/models/similar/widgets/selected_image_widget.dart';
import 'package:smart_shop/models/similar/widgets/send_image_button.dart';
import 'package:smart_shop/ui/product_details_screen.dart';

class SimilarScreen extends StatefulWidget {
  @override
  _SimilarScreenState createState() => _SimilarScreenState();
}

class _SimilarScreenState extends State<SimilarScreen> {
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  List<Map<String, dynamic>>? products;
  bool isLoading =
      false; // Indicates if the request for similar products is in progress
  bool isImageLoading = false; // Indicates if image upload is in progress

  /// Pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final imageBytes = await image.readAsBytes();
        setState(() {
          selectedImageBytes = imageBytes;
          selectedImageName = image.name;
        });
        print('Image selected: ${image.name}');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  /// Send the selected image to the server
  Future<void> _sendImage() async {
    if (selectedImageBytes == null || selectedImageName == null) {
      print('Please select an image first.');
      return;
    }

    setState(() {
      isImageLoading = true; // Show loading indicator while sending image
    });

    try {
      // Get server URL from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Permission')
          .doc('fTH5LwJQqAZwvtlRnfzu')
          .get();

      final data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('Server')) {
        final serverUrl = data['Server'];

        // Create a multipart request
        final request = http.MultipartRequest(
            'POST', Uri.parse('$serverUrl/similar_image'));

        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // Key for the file
            selectedImageBytes!, // Image bytes
            filename: selectedImageName,
            contentType: MediaType('image', 'jpeg'), // JPEG image
          ),
        );

        // Send the request and handle the response
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse != null && jsonResponse['similar_images'] != null) {
            final List<String> similarImageIds =
                List<String>.from(jsonResponse['similar_images']);
            _fetchProductDetails(similarImageIds);
          } else {
            print('No similar images found in the response.');
          }
        } else {
          print('Failed to send image. Status code: ${response.statusCode}');
        }
      } else {
        print('Server URL not found in Firestore document');
      }
    } catch (e) {
      print('Error sending image: $e');
    } finally {
      setState(() {
        isImageLoading = false; // Hide loading after processing
      });
    }
  }

  /// Fetch product details from Firestore based on similar image IDs
  Future<void> _fetchProductDetails(List<String> similarImageIds) async {
    setState(() {
      isLoading = true; // Show loading indicator while fetching products
    });

    try {
      List<Map<String, dynamic>> fetchedProducts = [];

      for (String id in similarImageIds) {
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(id)
            .get();

        if (productDoc.exists) {
          fetchedProducts.add(productDoc.data() as Map<String, dynamic>);
        }
      }

      setState(() {
        products = fetchedProducts.isEmpty
            ? null
            : fetchedProducts; // Handle empty products
        isLoading = false; // Hide loading after data is fetched
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching product details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Similar Products',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF615EFC),
        // backbutton white color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectedImageWidget(
              selectedImageBytes: selectedImageBytes,
              onPickImage: _pickImage,
            ),
            SizedBox(height: 20),
            SendImageButton(
              onSendImage: _sendImage,
              selectedImageBytes: selectedImageBytes,
            ),
            SizedBox(height: 20),
            if (isImageLoading)
              Center(child: CircularProgressIndicator(color: Color(0xFF615EFC)))
            else if (isLoading)
              Center(child: CircularProgressIndicator(color: Color(0xFF615EFC)))
            else if (products == null || products!.isEmpty)
              Center(
                  child:
                      Text('No products found', style: TextStyle(fontSize: 18)))
            else
              ProductGridView(
                products: products!,
                onProductTap: (product) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetails(product),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
