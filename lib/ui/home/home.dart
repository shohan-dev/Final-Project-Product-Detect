import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:smart_shop/ui/product_details_screen.dart';
import 'package:smart_shop/ui/search_screen.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  var carouselImages = <String>[].obs;
  var products = <Map<String, dynamic>>[].obs;
  var dotPosition = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCarouselImages();
    fetchProducts();
  }

  void fetchCarouselImages() async {
    try {
      QuerySnapshot qn =
          await _firestoreInstance.collection("carousel-slider").get();
      carouselImages.value =
          qn.docs.map((doc) => doc["img-path"] as String).toList();
    } catch (e) {
      print("Error fetching carousel images: $e");
    }
  }

  void fetchProducts() async {
    try {
      QuerySnapshot qn = await _firestoreInstance.collection("products").get();
      products.value = qn.docs.map((doc) {
        return {
          "product-name": doc["product-name"],
          "product-description": doc["product-description"],
          "product-price": doc["product-price"],
          "product-img": doc["product-img"],
        };
      }).toList();
    } catch (e) {
      print("Error fetching products: $e");
    }
  }
}

class Home extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.carouselImages.isEmpty &&
              controller.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar(context)),
                SliverToBoxAdapter(child: _buildCarousel()),
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(
                    "Products",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )),
                _buildGridProductList(),
              ],
            )),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
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
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide:
                        BorderSide(color: AppColors.deep_blue, width: 1.5),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide:
                        BorderSide(color: AppColors.deep_blue, width: 1.5),
                  ),
                  hintText: "Search by Text",
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.deep_blue),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
                ),
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const SearchScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2.5,
          child: CarouselSlider(
            items: controller.carouselImages
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CachedNetworkImage(imageUrl: item),
                    ))
                .toList(),
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              onPageChanged: (val, reason) =>
                  controller.dotPosition.value = val,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DotsIndicator(
              dotsCount: controller.carouselImages.isEmpty
                  ? 1
                  : controller.carouselImages.length,
              position: controller.dotPosition.value,
              decorator: DotsDecorator(
                activeColor: AppColors.deep_blue,
                color: AppColors.deep_blue.withOpacity(0.5),
                spacing: const EdgeInsets.all(5),
                activeSize: const Size(8, 8),
                size: const Size(5, 5),
              ),
            )),
      ],
    );
  }

  Widget _buildGridProductList() {
    return Obx(() => SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = controller.products[index];
              return GestureDetector(
                onTap: () => Get.to(() => ProductDetails(product)),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: product["product-img"][0],
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product["product-name"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Price: ${product["product-price"]} ৳",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            childCount: controller.products.length,
          ),
        ));
  }
}
