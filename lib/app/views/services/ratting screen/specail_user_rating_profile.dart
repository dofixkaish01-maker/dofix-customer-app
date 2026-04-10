import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/dashboard_controller.dart';

class SpecailUserRatttingProfile extends StatefulWidget {
  const SpecailUserRatttingProfile({super.key});

  @override
  State<SpecailUserRatttingProfile> createState() =>
      _SpecailUserRatttingProfileState();
}

class _SpecailUserRatttingProfileState
    extends State<SpecailUserRatttingProfile> {

  final controller = Get.find<DashBoardController>();

  @override
  void initState() {
    super.initState();

    /// API CALL AFTER BUILD
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getUserReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xE22178A8),
        title: const Text("User Reviews"),
      ),

      body: GetBuilder<DashBoardController>(
        builder: (controller) {

          /// LOADING
          if (controller.isReviewLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// EMPTY
          if (controller.reviewList.isEmpty) {
            return const Center(child: Text("No Reviews Found"));
          }

          String imageUrl =
              "https://panel.dofix.in/storage/profile/${controller.customerImage ?? ''}";

          return Column(
            children: [

              /// TOP PROFILE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [

                    /// PROFILE IMAGE
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: (controller.customerImage != null &&
                          controller.customerImage!.isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : null,
                      child: (controller.customerImage == null ||
                          controller.customerImage!.isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),

                    const SizedBox(height: 10),

                    /// NAME
                    Text(
                      controller.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// RATING
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.averageRating.round(),
                            (index) => const Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${controller.averageRating.toStringAsFixed(1)} • ${controller.reviewList.length} reviews",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "User Reviews",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// LIST
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.reviewList.length,
                  itemBuilder: (context, index) {
                    final review = controller.reviewList[index];
                    return _reviewCard(review);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ================= REVIEW CARD =================
  Widget _reviewCard(dynamic review) {

    /// SAFE DATA
    String serviceName =
        review["service_name"] ?? review["variant_key"] ?? "Service";

    int rating = review["review_rating"] ?? 0;

    String comment = review["review_comment"] ?? "No comment";

    String date = review["booking_date"] ?? "";

    List images = review["review_images"] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// SERVICE + RATING
          Row(
            children: [
              Expanded(
                child: Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Row(
                children: List.generate(
                  rating,
                      (index) => const Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          /// DATE
          Text(
            date,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),

          const SizedBox(height: 6),

          /// COMMENT
          Text(
            comment,
            style: const TextStyle(fontSize: 13),
          ),

          /// IMAGES
          if (images.isNotEmpty) ...[
            const SizedBox(height: 8),

            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, i) {
                  String imgUrl =
                      "https://panel.dofix.in/storage/review/${images[i]}";

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 8),

          Divider(color: Colors.grey.shade300, thickness: 0.6),
        ],
      ),
    );
  }
}