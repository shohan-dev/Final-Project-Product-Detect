import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'product_details_screen.dart';
import 'search_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> _carouselImages = [];
  var _dotPosition = 0;
  final List _products = [];
  final _firestoreInstance = FirebaseFirestore.instance;

  fetchCarouselImages() async {
    QuerySnapshot qn =
        await _firestoreInstance.collection("carousel-slider").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        _carouselImages.add(
          qn.docs[i]["img-path"],
        );
        print(qn.docs[i]["img-path"]);
      }
    });
    return qn.docs;
  }

  fetchProducts() async {
    QuerySnapshot qn = await _firestoreInstance.collection("products").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        _products.add({
          "product-name": qn.docs[i]["product-name"],
          "product-description": qn.docs[i]["product-description"],
          "product-price": qn.docs[i]["product-price"],
          "product-img": qn.docs[i]["product-img"],
        });
      }
    });
    return qn.docs;
  }

  @override
  void initState() {
    fetchCarouselImages();
    fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 35.h,
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200],
                        filled: true,
                        // Elevate design with a subtle shadow
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(50)), // More rounded
                          borderSide: BorderSide(
                              color: AppColors.deep_blue, width: 1.5),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(50)), // More rounded
                          borderSide: BorderSide(
                              color: AppColors.deep_blue, width: 1.5),
                        ),
                        hintText: "Search by Text",
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[
                              600], // Slightly darker grey for better visibility
                        ),
                        // Icon with a custom color and gradient for modern look
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.deep_blue),
                        // Padding for improved spacing
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 15.w),
                      ),
                      // On tap navigate to SearchScreen
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => const SearchScreen()),
                      ),
                    ),
                  ),
                ),

                // SizedBox(width: 10.w),
                // SizedBox(
                //   height: 35.0, // Adjust to your needs
                //   child: ElevatedButton.icon(
                //     onPressed: () {
                //       Get.to(() => const NextPage());
                //     },
                //     icon: const Icon(Iconsax.scan, color: AppColors.deep_blue),
                //     label: const Text(
                //       "Scan",
                //       style: TextStyle(color: AppColors.deep_blue),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 2.5,
            child: CarouselSlider(
              items: _carouselImages
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: CachedNetworkImage(imageUrl: item),
                      ))
                  .toList(),
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                onPageChanged: (val, carouselPageChangedReason) {
                  setState(() {
                    _dotPosition = val;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 1.h),
          DotsIndicator(
            dotsCount: _carouselImages.isEmpty ? 1 : _carouselImages.length,
            position: _dotPosition.toInt(),
            decorator: DotsDecorator(
              activeColor: AppColors.deep_blue,
              color: AppColors.deep_blue.withOpacity(0.5),
              spacing: const EdgeInsets.all(5),
              activeSize: const Size(8, 8),
              size: const Size(5, 5),
            ),
          ),
          SizedBox(height: 0.h),
          // cardview for products
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductDetails(_products[index])),
                  ),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: _products[index]["product-img"][0]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "${_products[index]["product-name"]}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "Price: ${_products[index]["product-price"].toString()} ৳",
                          style: const TextStyle(
                              fontSize: 15, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
