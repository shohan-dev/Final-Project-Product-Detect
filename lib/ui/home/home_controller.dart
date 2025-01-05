import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetails(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product["product-name"]),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: CachedNetworkImage(
                imageUrl: product["product-img"][0],
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                product["product-name"],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                product["product-description"],
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Price: ${product["product-price"]} ৳",
                style: const TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
