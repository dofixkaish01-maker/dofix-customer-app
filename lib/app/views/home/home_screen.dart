import 'package:carousel_slider/carousel_slider.dart';
import 'package:do_fix/app/views/home/component/banner_widget.dart';
import 'package:do_fix/app/views/home/component/category_components.dart';
import 'package:do_fix/app/views/home/refer%20screen/refer_earn_screen.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/styles.dart';
import '../dashboard/dashboard_screen.dart';
import 'component/horizontal_view.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // class level pe rakhna (State me)

  final bookingController = Get.find<BookingController>();
  List<String> pinnedCategoryIds = [
    "1", // AC
    "3", // Plumber
    "5", // Electrician
    "7", // Cleaning
    "9", // Painting
    "11", // Pest Control
  ];
  final List<String> staticBanners = [
    'assets/banner/AC Installation & Repair.png',
    'assets/banner/Home Appliances Repair.png',
    'assets/banner/Home Interior & Renovation.png',
    'assets/banner/Home Painting.png',
    'assets/banner/Electrician Services.png',
    'assets/banner/Cleaning Services.png',
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

      controller.getFeaturedCategories(limit: "6", offset: "1", isShowLoading: true);
      controller.getTopRated("10", "1", false);
      controller.getQuickRepair("10", "1", false);
      controller.getBanners();
      controller.homeSubCategoryList;

      /// IMPORTANT PART (HOME PE SUB CATEGORY LOAD)
      if ((controller.categoryList?.data ?? []).isNotEmpty) {
        final firstCategory = controller.categoryList!.data![0];

        controller.getCategoriesToServices(
          id: firstCategory.id.toString(),
          limit: "10",
          offset: "1",
          isLoading: false,
        );
      }
    });
  }


  // ADDED: refresh function for pull to refresh
// ADDED: pull to refresh handler
//   Future<void> _onRefresh() async {
//     final controller = Get.find<DashBoardController>();
//
//     // ADDED: repeat initial load logic
//     controller.onInit(); // safest & zero error
//
//     controller.update(); // refresh UI
//   }

  Future<void> _onRefresh() async {
    final controller = Get.find<DashBoardController>();

    await Future.wait([
      controller.getFeaturedCategories(limit: "6", offset: "1"),
      controller.getTopRated("10", "1", false),
      controller.getQuickRepair("10", "1", false),
      controller.getBanners(),
    ]);

    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
        builder: (controller) {

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

                        await dash.getFeaturedCategories(limit: "50", offset: "1", isShowLoading: false);

                        Get.offAll(
                          DashboardScreen(
                            key: GlobalKey<DashboardScreenState>(),
                            pageIndex: 1,
                          ),
                        );
                        // InkWell(
                        //   onTap: () {
                        //     Get.offAll(
                        //       DashboardScreen(
                        //         key: GlobalKey<DashboardScreenState>(),
                        //         pageIndex: 1,
                        //       ),
                        //     );
                        //   },
                        //   child: Image.asset('assets/images/Instant Repairs at Your Fingertips! (2).PNG'),
                        // );
                      },
                      child: Image.asset('assets/images/instant_repairs.png',fit: BoxFit.contain,),),
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

                        /// Yaha tumhara SEE button add ho gaya
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
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Card(
                      elevation: 6,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      clipBehavior: Clip.antiAlias,

                      child: Padding(
                        padding: const EdgeInsets.all(10),

                        child: Column(
                          children: [

                            /// 🔥 CAROUSEL INSIDE CARD
                            CarouselSlider.builder(
                              itemCount: staticBanners.length,
                              itemBuilder: (context, index, realIndex) {

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [

                                      /// 🖼️ ZOOM IMAGE EFFECT
                                      Positioned.fill(
                                        child: Transform.scale(
                                          scale: 1.1, // 🔥 zoom feel
                                          child: Image.asset(
                                            staticBanners[index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      /// 🌑 SOFT GRADIENT
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

                                      /// 🏷️ TEXT AREA
                                      Positioned(
                                        left: 14,
                                        right: 14,
                                        bottom: 12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Text(
                                              staticBanners[index]
                                                  .split('/')
                                                  .last
                                                  .replaceAll('.png', ''),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
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
                                );
                              },

                              options: CarouselOptions(
                                height: 165,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                autoPlayAnimationDuration: const Duration(milliseconds: 700),
                                enlargeCenterPage: true,
                                viewportFraction: 1, // 🔥 full width inside card
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// 🔵 DOTS INSIDE CARD
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(staticBanners.length, (index) {
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

                  // ///  Top Rated Services
                  // if ((controller.topRated?.data ?? []).isNotEmpty)
                  //   buildHomeSection(
                  //     title: "Top Rated Services",
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         color: Colors.grey.shade50,
                  //         borderRadius: BorderRadius.circular(16),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black.withOpacity(0.05),
                  //             blurRadius: 10,
                  //             offset: const Offset(0, 5),
                  //           ),
                  //         ],
                  //       ),
                  //       padding: const EdgeInsets.all(12),
                  //       child: HorizontalAnimatedList(
                  //         imageHeight: 190,
                  //         data: controller.topRated!,
                  //         heading: '',
                  //       ),
                  //     ),
                  //   ),

                  //******* working ***********
                  if ((controller.subCategoryModelListing?.data ?? []).isNotEmpty)
                    SizedBox(
                      height: 200, // total height of card
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.subCategoryModelListing!.data!.length,

                        separatorBuilder: (_, __) => const SizedBox(width: 14),

                        itemBuilder: (context, index) {
                          final subCategory = controller.subCategoryModelListing!.data![index];
                          final isSelected = controller.selectedSubCategories.contains(subCategory);

                          return GestureDetector(
                            onTap: () {
                              controller.getCategoriesToServices(
                                id: subCategory.id.toString(),
                                limit: '10',
                                offset: "1",
                                isLoading: true,
                              );

                              controller.selectedSubCategories.clear();
                              controller.selectedSubCategories.add(subCategory);

                              controller.update();
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,

                              ///  SCREEN WIDTH ka half - spacing adjust
                              width: (Get.size.width - 16 * 2 - 14) / 2,

                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF207FA7).withOpacity(0.08)
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),

                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    /// Image
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

                                    /// Title
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

                                    /// indicator
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      height: 4,
                                      width: isSelected ? 20 : 0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF207FA7),
                                        borderRadius: BorderRadius.circular(10),
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



                  ///  Second Banner
                  if (controller.banner2.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: BannerComponent(
                        bannerList: controller.banner2,
                      ),
                    ),

                  // ///  Quick Repairs
                  // if ((controller.quickRepair?.data ?? []).isNotEmpty)
                  //   buildHomeSection(
                  //     title: "Quick Repairs",
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         color: Colors.grey.shade50,
                  //         borderRadius: BorderRadius.circular(16),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black.withOpacity(0.05),
                  //             blurRadius: 10,
                  //             offset: const Offset(0, 5),
                  //           ),
                  //         ],
                  //       ),
                  //       padding: const EdgeInsets.all(12),
                  //       child: HorizontalAnimatedList(
                  //         imageHeight: 170,
                  //         data: controller.quickRepair!,
                  //         heading: '',
                  //       ),
                  //     ),
                  //   ),

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

                  const SizedBox(height: 20),
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

        /// Section Body
        child,
      ],
    ),
  );
}
