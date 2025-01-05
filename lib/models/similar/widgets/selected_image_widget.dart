import 'dart:typed_data';
import 'package:flutter/material.dart';

class SelectedImageWidget extends StatelessWidget {
  final Uint8List? selectedImageBytes;
  final VoidCallback onPickImage;

  const SelectedImageWidget({
    required this.selectedImageBytes,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return selectedImageBytes != null
        ? Image.memory(selectedImageBytes!, height: 200)
        : ElevatedButton(
            onPressed: onPickImage,
            child: Text(
              'Pick Image',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF615EFC),
            ),
          );
  }
}
