import 'dart:convert'; // For JSON decoding
import 'dart:typed_data'; // For handling image bytes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:smart_shop/models/similar/widgets/product_grid_view.dart';
import 'package:smart_shop/models/similar/widgets/selected_image_widget.dart';
import 'package:smart_shop/models/similar/widgets/send_image_button.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/product_details_screen.dart';

class SimilarScreen extends StatefulWidget {
  @override
  _SimilarScreenState createState() => _SimilarScreenState();
}

class _SimilarScreenState extends State<SimilarScreen> {
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  List<Map<String, dynamic>>? products;
  bool isLoading = false;
  bool isImageLoading = false;

  // serverUrl get
  Future<bool> getServerresponse() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Permission')
        .doc('fTH5LwJQqAZwvtlRnfzu')
        .get();

    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data.containsKey('Server')) {
      final serverUrl = data['Server'];
      final response = await http.get(Uri.parse('$serverUrl/health'));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  // Method to show the bottom sheet for selecting camera or gallery
  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildBottomSheetContent(
          context,
          'Select an image source',
          (ImageSource source) {
            _pickImage(source);
          },
        );
      },
    );
  }

  /// Pick an image from the selected source (camera or gallery)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          isImageLoading =
              true; // Start loading indicator while processing image
        });
        final imageBytes = await image.readAsBytes();
        setState(() {
          selectedImageBytes = imageBytes;
          selectedImageName = image.name;
          isImageLoading = false; // Stop loading after image is loaded
        });
        print('Image selected: ${image.name}');
      }
    } catch (e) {
      setState(() {
        isImageLoading = false; // Ensure loading stops on error
      });
      print('Error picking image: $e');
    }
  }

  /// Compress the image to be less than 200KB
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    return await compute(_compressImageSync, imageBytes);
  }

  static Uint8List _compressImageSync(Uint8List imageBytes) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    int quality = 100;
    Uint8List compressedBytes =
        Uint8List.fromList(img.encodeJpg(image, quality: quality));

    while (compressedBytes.length > 200 * 1024 && quality > 10) {
      quality -= 10;
      compressedBytes =
          Uint8List.fromList(img.encodeJpg(image, quality: quality));
    }
    print('Compressed image size: ${compressedBytes.length} bytes');

    return compressedBytes;
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
      // Compress the image
      Uint8List compressedImageBytes =
          await _compressImage(selectedImageBytes!);

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
            compressedImageBytes, // Compressed image bytes
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
        title: const Text('Find Similar Products',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF615EFC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<bool>(
        future: getServerresponse(),
        builder: (context, snapshot) {
          // Show loading screen while waiting for the response
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF615EFC)));
          }

          // Check for error or false response
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Server is unavailable')),
              );
            });
            return const Center(
                child: Text('Server is unavailable',
                    style: TextStyle(fontSize: 18)));
          }

          // Response is successful
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => _showImageSourceSelection(
                      context), // Tap to choose image source
                  child: SelectedImageWidget(
                    selectedImageBytes: selectedImageBytes,
                    onPickImage: () => _showImageSourceSelection(context),
                  ),
                ),
                const SizedBox(height: 20),
                SendImageButton(
                  onSendImage: _sendImage,
                  selectedImageBytes: selectedImageBytes,
                ),
                const SizedBox(height: 20),
                if (isImageLoading)
                  const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF615EFC)))
                else if (isLoading)
                  const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF615EFC)))
                else if (products == null || products!.isEmpty)
                  const Center(
                      child: Text('No products found',
                          style: TextStyle(fontSize: 18)))
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
          );
        },
      ),
    );
  }

  Widget _buildBottomSheetContent(
      BuildContext context, String text, Function(ImageSource) onSelect) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.camera_alt,
                color: AppColors.splash_colors), // Color icon to match theme
            title: const Text('Camera', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              onSelect(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo,
                color: AppColors.splash_colors), // Color icon to match theme
            title: const Text('Gallery', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              onSelect(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
