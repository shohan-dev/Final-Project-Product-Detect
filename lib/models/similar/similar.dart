import 'dart:convert'; // For JSON decoding
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SimilarScreen extends StatefulWidget {
  @override
  _SimilarScreenState createState() => _SimilarScreenState();
}

class _SimilarScreenState extends State<SimilarScreen> {
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  List<Map<String, dynamic>>? products;
  bool isLoading = false; // To manage loading state

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
      isLoading = true; // Show loading indicator when sending image
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
            selectedImageBytes!,
            filename: selectedImageName,
            contentType: MediaType('image', 'jpeg'), // all image type
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
    }
  }

  /// Fetch product details from Firestore
  Future<void> _fetchProductDetails(List<String> similarImageIds) async {
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
        products = fetchedProducts;
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
        backgroundColor: Color(0xFF615EFC), // Primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            selectedImageBytes != null
                ? Image.memory(selectedImageBytes!, height: 200)
                : ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF615EFC), // Primary color
                    ),
                  ),
            SizedBox(height: 20),
            if (selectedImageBytes != null)
              ElevatedButton(
                onPressed: _sendImage,
                child: Text('Send Image',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF615EFC), // Primary color
                ),
              ),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator(color: Color(0xFF615EFC)))
            else
              Expanded(
                child: products != null
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products!.length,
                        itemBuilder: (context, index) {
                          final product = products![index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to the product details page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: product['product-img'][0] != null
                                        ? Image.network(
                                            product['product-img'][0],
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(Icons.image, size: 50),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          product['product-name'] ??
                                              'Product Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          product['product-price'] != null
                                              ? '\$${product['product-price']}'
                                              : 'Price Unavailable',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(child: Text('No products found')),
              ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailsScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['product-name'] ?? 'Product Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF615EFC), // Primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              product['product-img'][0] ?? '',
              fit: BoxFit.cover,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              product['product-name'] ?? 'Product Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              product['product-price'] != null
                  ? '\$${product['product-price']}'
                  : 'Price Unavailable',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              product['product-description'] ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
