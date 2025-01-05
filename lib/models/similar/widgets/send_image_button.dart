import 'dart:typed_data';
import 'package:flutter/material.dart';

class SendImageButton extends StatelessWidget {
  final VoidCallback onSendImage;
  final Uint8List? selectedImageBytes;

  const SendImageButton({
    required this.onSendImage,
    required this.selectedImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return selectedImageBytes != null
        ? ElevatedButton(
            onPressed: onSendImage,
            child:  Text(
              'Send Image',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF615EFC),
            ),
          )
        : const SizedBox.shrink();
  }
}
