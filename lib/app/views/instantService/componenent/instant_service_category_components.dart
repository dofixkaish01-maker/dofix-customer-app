import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../controllers/dashboard_controller.dart';
import '../../../../model/all_category_model.dart';
import '../../../../widgets/custom_image_viewer.dart';
import '../../home/SubScreens/category_to_services.dart';

class InstantServiceCategoryComponents extends StatefulWidget {
  const InstantServiceCategoryComponents({
    super.key,
    required this.allCategoryModel,
    this.isShowSeeAll = true,
    required this.width,
  });

  final AllCategoryModel? allCategoryModel;
  final bool isShowSeeAll;
  final double width;

  @override
  State<InstantServiceCategoryComponents> createState() =>
      _InstantServiceCategoryComponentsState();
}

class _InstantServiceCategoryComponentsState
    extends State<InstantServiceCategoryComponents> {

  int? pressedIndex;

  @override
  Widget build(BuildContext context) {

    final list = widget.allCategoryModel?.content?.data;

    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Stack(
        children: [
          /// BACKGROUND LOTTIE ANIMATION
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie_animation/background_animation.json',
              fit: BoxFit.cover,
              repeat: true,
              animate: true,
            ),
          ),
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (widget.isShowSeeAll)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  "Instant Services",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 14,
                childAspectRatio: .9,
              ),

              itemBuilder: (context, i) {

                final cat = list[i];
                final isPressed = pressedIndex == i;

                return GestureDetector(

                  onTapDown: (_) {
                    setState(() {
                      pressedIndex = i;
                    });
                  },

                  onTapUp: (_) {

                    setState(() {
                      pressedIndex = null;
                    });

                    final controller = Get.find<DashBoardController>();

                    controller.selectedCategoryName = cat.name ?? "";

                    controller.getCategoriesToSubCategories(
                      id: cat.id.toString(),
                      limit: '10',
                      offset: "1",
                    );

                    Get.to(() => const CategoryToServices());
                  },

                  onTapCancel: () {
                    setState(() {
                      pressedIndex = null;
                    });
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),

                    transform: Matrix4.diagonal3Values(
                      isPressed ? 0.95 : 1,
                      isPressed ? 0.95 : 1,
                      1,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// IMAGE WITH OVERLAY
                        Stack(
                          children: [

                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18)),

                              child: CustomNetworkImageWidget(
                                width: double.infinity,
                                height: 120,
                                image: cat.imageFullPath ?? "",
                              ),
                            ),

                            /// GRADIENT OVERLAY
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18)),

                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(.2)
                                  ],
                                ),
                              ),
                            ),

                            /// COMPACT INSTANT BADGE
                            Positioned(
                              top: 8,
                              left: 8,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // subtle blur
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // smaller
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange.withOpacity(0.85),
                                          Colors.deepOrange.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.25),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Text(
                                      "⚡ Instant",
                                      style: TextStyle(
                                        fontSize: 9, // smaller font
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                            blurRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// TEXT AREA
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                cat.name ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [

                Column(
                  children: [
                    Icon(Icons.flash_on, color: Colors.orange, size: 22),
                    SizedBox(height: 4),
                    Text(
                      "Quick Service",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                Column(
                  children: [
                    Icon(Icons.verified_outlined, color: Colors.green, size: 22),
                    SizedBox(height: 4),
                    Text(
                      "Verified Experts",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                Column(
                  children: [
                    Icon(Icons.support_agent, color: Colors.blue, size: 22),
                    SizedBox(height: 4),
                    Text(
                      "24/7 Support",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                "Professional help when you need it most",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        )],
      ),
    );
  }
}