import 'package:flutter/material.dart';

class ProductGridView extends StatelessWidget {
  final List<Map<String, dynamic>>? products;
  final Function(Map<String, dynamic>) onProductTap;

  const ProductGridView({
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return products != null
        ? Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products!.length,
              itemBuilder: (context, index) {
                final product = products![index];
                return GestureDetector(
                  onTap: () => onProductTap(product),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                product['product-name'] ?? 'Product Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product['product-price'] != null
                                    ? '৳${product['product-price']}'
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
            ),
          )
        : Center(child: Text('No products found'));
  }
}
