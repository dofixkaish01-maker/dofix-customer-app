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
  final bookingController = Get.find<BookingController>();
  List<String> pinnedCategoryIds = [
    "1", // AC
    "3", // Plumber
    "5", // Electrician
    "7", // Cleaning
    "9", // Painting
    "11", // Pest Control
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

      // IMPORTANT FIX – 6 ki jagah FULL DATA
      controller.getFeaturedCategories("6", "1");

      controller.getTopRated("10", "1", false);
      controller.getQuickRepair("10", "1", false);
      controller.getBanners();
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
      controller.getFeaturedCategories("6", "1"),
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

                        await dash.getFeaturedCategories("50", "1", true);

                        Get.offAll(
                          DashboardScreen(
                            key: GlobalKey<DashboardScreenState>(),
                            pageIndex: 1,
                          ),
                        );
                        InkWell(
                          onTap: () {
                            Get.offAll(
                              DashboardScreen(
                                key: GlobalKey<DashboardScreenState>(),
                                pageIndex: 1,
                              ),
                            );
                          },
                          child: Image.asset('assets/images/Instant Repairs at Your Fingertips! (2).PNG'),
                        );
                      },
                      child: Image.asset('assets/images/Instant Repairs at Your Fingertips! (2).PNG')),
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
                  if (controller.banners1.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias, // VERY IMPORTANT
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BannerComponent(
                            bannerList: controller.banners1,
                          ),
                        ),
                      ),
                    ),

                  ///  Top Rated Services
                  if ((controller.topRated?.data ?? []).isNotEmpty)
                    buildHomeSection(
                      title: "Top Rated Services",
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: HorizontalAnimatedList(
                          imageHeight: 190,
                          data: controller.topRated!,
                          heading: '',
                        ),
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

                  ///  Quick Repairs
                  if ((controller.quickRepair?.data ?? []).isNotEmpty)
                    buildHomeSection(
                      title: "Quick Repairs",
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: HorizontalAnimatedList(
                          imageHeight: 170,
                          data: controller.quickRepair!,
                          heading: '',
                        ),
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
