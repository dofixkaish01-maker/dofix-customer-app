import 'package:carousel_slider/carousel_slider.dart';
import 'package:do_fix/app/views/home/component/category_components.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/service_model.dart';
import '../dashboard/dashboard_screen.dart';
import 'component/horizontal_view.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final bookingController = Get.find<BookingController>();
  List<String> pinnedCategoryIds = [
    "1", // AC
    "3", // Plumber
    "5", // Electrician
    "7", // Cleaning
    "9", // Painting
    "11", // Pest Control
  ];
  final List<BannerModel> staticBanners = [
    BannerModel(image: 'assets/banner/ac.png'),
    BannerModel(image: 'assets/banner/home_ap.png'),
    BannerModel(image: 'assets/banner/home.png'),
    BannerModel(image: 'assets/banner/home_panting.png'),
    BannerModel(image: 'assets/banner/electric.png'),
    BannerModel(image: 'assets/banner/cleaning.png')
  ];

  @override
  // void initState() {
  //   super.initState();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     // showLoading();
  //     // Call visitChildElements() here
  //     // Get.find<DashBoardController>().handleLocationPermission(context);
  //     // final permission = await Geolocator.checkPermission();
  //
  //     // TODO : Unneccesarry call
  //     // if (permission == LocationPermission.always ||
  //     //     permission == LocationPermission.whileInUse) {
  //     //   Get.find<DashBoardController>().getFeaturedCategories("6", "1");
  //     // }
  //     // hideLoading();
  //   });
  // }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<DashBoardController>();

      controller.getFeaturedCategories(
          limit: "6", offset: "1", isShowLoading: true);
      controller.getTopRated("10", "1", true);
      controller.getQuickRepair("10", "1", false);
      controller.getBanners();
      controller.homeSubCategoryList;

      /// IMPORTANT PART (HOME PE SUB CATEGORY LOAD)
      //******** iske wajah se back karne pe re-direct ho ja raha tha (service screen) pe *******
      // if ((controller.categoryList?.data ?? []).isNotEmpty) {
      //   final firstCategory = controller.categoryList!.data![0];
      //
      //   controller.getCategoriesToServices(
      //     id: firstCategory.id.toString(),
      //     limit: "10",
      //     offset: "1",
      //     isLoading: false,
      //   );
      // }
      controller.getACServices();
    });
  }

  Future<void> _onRefresh() async {
    final controller = Get.find<DashBoardController>();

    await Future.wait([
      controller.getFeaturedCategories(limit: "6", offset: "1"),
      controller.getTopRated("10", "1", true),
      controller.getQuickRepair("10", "1", false),
      controller.getBanners(),
    ]);

    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      final allCategories = controller.categoryList?.data ?? [];

      final pinnedCategories = allCategories
          .where((cat) => pinnedCategoryIds.contains(cat.id.toString()))
          .toList();
      print("ALL CATEGORIES COUNT: ${allCategories.length}");
      print("PINNED COUNT: ${pinnedCategories.length}");

      return Scaffold(
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              InkWell(
                onTap: () async {
                  final dash = Get.find<DashBoardController>();

                  await dash.getFeaturedCategories(
                      limit: "50", offset: "1", isShowLoading: false);

                  Get.offAll(
                    DashboardScreen(
                      key: GlobalKey<DashboardScreenState>(),
                      pageIndex: 1,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/instant_repairs.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 15),

              /// Heading Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          "All Services",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        final dash = Get.find<DashBoardController>();

                        await dash.getFeaturedCategories(
                          limit: "50",
                          offset: "1",
                          isShowLoading: false,
                        );

                        Get.offAll(
                          DashboardScreen(
                            key: GlobalKey<DashboardScreenState>(),
                            pageIndex: 1,
                          ),
                        );
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Pinned / All Categories
              if (allCategories.isNotEmpty)
                CategoryComponents(
                  categoryList: CategoryModel(
                    data: pinnedCategories.isNotEmpty
                        ? pinnedCategories
                        : allCategories,
                  ),
                  width: MediaQuery.of(context).size.width / 3 - 18,
                  isShowSeeAll: true,
                ),

              /// Our Features
              const Padding(
                padding: EdgeInsets.only(left: 14, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Our Features",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              /// Our features (Banner Slider inside Card)
              // if (controller.banners1.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              //     child: Card(
              //       elevation: 5,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //       clipBehavior: Clip.antiAlias, // VERY IMPORTANT
              //       child: Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: BannerComponent(
              //           bannerList: controller.banners1,
              //         ),
              //       ),
              //     ),
              //   ),

              // carousel slider images
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Card(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        /// CAROUSEL INSIDE CARD
                        CarouselSlider.builder(
                          itemCount: staticBanners.length,
                          itemBuilder: (context, index, realIndex) {
                            final banner = staticBanners[index];

                            final controller = Get.find<DashBoardController>();
                            final allCategories =
                                controller.categoryList?.data ?? [];

                            if (allCategories.isEmpty) {
                              return const SizedBox();
                            }

                            /// Dynamic category mapping
                            final category =
                                allCategories[index % allCategories.length];

                            return InkWell(
                                onTap: () {
                                  print(
                                      "CLICKED BANNER CATEGORY ID = ${category.id}");

                                  controller.getCategoriesToSubCategories(
                                    id: category.id.toString(),
                                    limit: '10',
                                    offset: "1",
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      /// ZOOM IMAGE EFFECT
                                      Positioned.fill(
                                        child: Transform.scale(
                                          scale: 1.10,
                                          child: Image.asset(
                                            banner.image,
                                          ),
                                        ),
                                      ),

                                      /// SOFT GRADIENT
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.55),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      /// ️ TEXT AREA
                                      Positioned(
                                        left: 14,
                                        right: 14,
                                        bottom: 12,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                "Explore",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          },
                          options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 700),
                            enlargeCenterPage: true,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// DOTS INSIDE CARD
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(staticBanners.length, (index) {
                            final isActive = _currentIndex == index;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 6,
                              width: isActive ? 18 : 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF207FA7)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if ((controller.topRated?.data ?? []).isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Heading (Outside Card)
                      const Text(
                        "AC Repair & Installation",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      //working ***********************************
                      GetBuilder<DashBoardController>(
                        builder: (controller) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: HorizontalAnimatedList(
                              key: ValueKey(controller.topRated?.data?.length ??
                                  0), // rebuild fix
                              imageHeight: 195,
                              data: controller.topRated ?? Services(data: []),
                              heading: '',
                            ),
                          );
                        },
                      )

                      /// Card
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(16),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.black.withOpacity(0.05),
                      //         blurRadius: 10,
                      //         offset: const Offset(0, 4),
                      //       ),
                      //     ],
                      //   ),
                      //   padding: const EdgeInsets.all(12),
                      //   child: HorizontalAnimatedList(
                      //     imageHeight: 195,
                      //     data: controller.topRated ?? Services(data: []),
                      //     heading: '',
                      //   ),
                      // ),
                    ],
                  ),
                ),
              if ((controller.subCategoryModelListing?.data ?? []).isNotEmpty)
                SizedBox(
                  height: 230, // 🔹 thoda bada height (text + list ke liye)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 Heading
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Services Viewed Recently",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔹 ListView ko Expanded me wrap karo
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              controller.subCategoryModelListing!.data!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final subCategory = controller
                                .subCategoryModelListing!.data![index];

                            final isSelected = controller.selectedSubCategories
                                .contains(subCategory);

                            return GestureDetector(
                              onTap: () {
                                controller.getCategoriesToServices(
                                  id: subCategory.id.toString(),
                                  limit: '10',
                                  offset: "1",
                                  isLoading: true,
                                );

                                controller.selectedSubCategories.clear();
                                controller.selectedSubCategories
                                    .add(subCategory);

                                controller.update();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                width: (Get.size.width - 16 * 2 - 14) / 2,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF207FA7)
                                          .withOpacity(0.08)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF207FA7)
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          subCategory.thumbnailFullPath ?? "",
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        subCategory.name ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFF207FA7)
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        height: 4,
                                        width: isSelected ? 20 : 0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF207FA7),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // ///  Second Banner
              // if (controller.banner2.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              //     child: BannerComponent(
              //       bannerList: controller.banner2,
              //     ),
              //   ),

              if ((controller.quickRepair?.data ?? []).isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Heading (Outside Card)
                      const Text(
                        "Cleaning Services",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: HorizontalAnimatedList(
                          imageHeight: 177,
                          data: controller.quickRepair ?? Services(data: []),
                          heading: '',
                        ),
                      ),
                    ],
                  ),
                ),
              // /// Refer & Earn
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: GestureDetector(
              //     onTap: () async {
              //       final authController = Get.find<AuthController>();
              //       bool isGuest = await authController.returnIsGuest();
              //
              //       if (isGuest) {
              //         authController.checkIfGuest();
              //       } else {
              //         Get.to(() => ReferEarnScreen());
              //       }
              //     },
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(14),
              //         gradient: const LinearGradient(
              //           begin: Alignment.topLeft,
              //           end: Alignment.bottomRight,
              //           colors: [
              //             Color(0xff266a8a),
              //             Color(0xff125778),
              //           ],
              //         ),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withOpacity(.25),
              //             blurRadius: 10,
              //             offset: Offset(0, 4),
              //           ),
              //         ],
              //       ),
              //       child: Row(
              //         children: [
              //           Container(
              //             padding: const EdgeInsets.all(10),
              //             decoration: BoxDecoration(
              //               color: Colors.white.withOpacity(.15),
              //               borderRadius: BorderRadius.circular(10),
              //             ),
              //             child: const Icon(
              //               Icons.card_giftcard,
              //               color: Colors.white,
              //               size: 26,
              //             ),
              //           ),
              //           const SizedBox(width: 14),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   "Refer & Earn ₹150",
              //                   style: albertSansRegular.copyWith(
              //                     fontSize: Dimensions.fontSize15,
              //                     fontWeight: FontWeight.w600,
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 6),
              //                 Text(
              //                   "Invite friends & earn rewards on every booking",
              //                   style: albertSansRegular.copyWith(
              //                     fontSize: Dimensions.fontSize12,
              //                     color: Colors.white70,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           const Icon(
              //             Icons.arrow_forward_ios_rounded,
              //             color: Colors.white70,
              //             size: 18,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              buildDoFixFooter(),
            ],
          ),
        ),
      );
    });
  }
}

Widget buildHomeSection({
  required String title,
  required Widget child,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        /// Heading
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // const Text(
            //   "See All",
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Colors.blue,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

Widget buildDoFixFooter() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF4FBFF),
          Color(0xFFEAF6FB),
        ],
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      boxShadow: [
        ///  main floating shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 22,
          spreadRadius: 2,
          offset: const Offset(0, -6),
        ),

        ///  soft light highlight
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 12,
          offset: const Offset(0, -2),
        ),
      ],
      border: Border.all(
        color: const Color(0xFF207FA7).withOpacity(0.12),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// LOGO CIRCLE WITH SOFT GLOW
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF207FA7).withOpacity(0.18),
                const Color(0xFF207FA7).withOpacity(0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF207FA7).withOpacity(0.25),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ],
          ),
          child: Image.asset(
            "assets/icons/ic_logo.png",
            height: 36,
            width: 36,
          ),
        ),

        const SizedBox(height: 14),

        /// TITLE
        const Text(
          "Trusted Hands for Every Home",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0E2A35),
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(height: 6),

        /// POWERED BY
        const Text(
          "Powered by DoFix",
          style: TextStyle(
            color: Color(0xFF207FA7),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        // DESCRIPTION
        const Text(
          "Our vision is to simplify home services by connecting customers with verified professionals, ensuring quality, affordability, and convenience at your doorstep.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF5A6B72),
            fontSize: 12.5,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 16),

        /// GRADIENT LINE
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF207FA7),
                Color(0xFF125778),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 10),

        /// COPYRIGHT
        const Text(
          "© 2025 DoFix. All rights reserved.",
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF8A9AA1),
          ),
        ),
      ],
    ),
  );
}

class BannerModel {
  final String image;

  BannerModel({required this.image});
}
