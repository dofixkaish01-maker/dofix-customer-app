import 'package:do_fix/app/views/dashboard/dashboard_screen.dart';
import 'package:do_fix/app/views/home/component/banner_widget.dart';
import 'package:do_fix/app/views/home/component/category_components.dart';
import 'package:do_fix/app/views/home/refer%20screen/refer_earn_screen.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/service_model.dart';
import 'component/horizontal_view.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bookingController = Get.find<BookingController>();

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

    await controller.getFeaturedCategories("6", "1");
    await controller.getTopRated("10", "1", false);
    await controller.getQuickRepair("10", "1", false);
    await controller.getBanners();

    controller.update();
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: _onRefresh,//for refresh page
          color: Color(0xff227FA8),
          child:SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
            children: [
                InkWell(
                    onTap: () {
                      Get.offAll(DashboardScreen(
                          key: GlobalKey<DashboardScreenState>(), pageIndex: 1));
                    },
                    child: Image.asset('assets/images/top_banner_image.png')),
                CategoryComponents(
                  categoryList:
                      controller.categoryList ?? CategoryModel(data: []),
                  width: MediaQuery.of(context).size.width / 3 - 18,
                  isShowSeeAll: true,
                ),
                BannerComponent(bannerList: controller.banners1
                    // .map(
                    //   (e) => BannerItem(
                    //     imageUrl: e.imageUrl,
                    //     bannertype: e.bannertype,
                    //     onTap: () => () {
                    //       print("onClick: ${e.redirectId}");
                    //       print('Tapped: ${e.imageUrl}');
                    //       Get.offAll(
                    //         DashboardScreen(
                    //           key: GlobalKey<DashboardScreenState>(),
                    //           pageIndex: 1,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // )
                    // .toList(),
                    ),
                Visibility(
                    visible:
                        ((controller.topRated ?? Services(data: [])).data ?? [])
                            .isNotEmpty,
                    child: SizedBox(
                      height: 20,
                    )),
                Visibility(
                    visible:
                        ((controller.topRated ?? Services(data: [])).data ?? [])
                            .isNotEmpty,
                    child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        padding: EdgeInsets.all(8),
                        child: HorizontalAnimatedList(
                          imageHeight: 195,
                          data: controller.topRated ?? Services(data: []),
                          heading: 'Top Rated Services',
                        ))),
                Visibility(
                  visible:
                      ((controller.topRated ?? Services(data: [])).data ?? [])
                          .isNotEmpty,
                  child: SizedBox(
                    height: 20,
                  ),
                ),
                BannerComponent(bannerList: controller.banner2
                    // .map((e) => BannerItem(
                    //       bannertype: e.bannertype,
                    //       imageUrl: e.imageUrl,
                    //       onTap: () {
                    //         try {
                    //           print(
                    //               "category id: ${e.redirectId}, ${e.bannertype}");
                    //           if (e.bannertype == "catgory") {
                    //             Get.find<DashBoardController>()
                    //                 .getCategoriesToSubCategories(
                    //                     id: e.redirectId.toString(),
                    //                     limit: '10',
                    //                     offset: "1");
                    //           } else if (e.bannertype == "service") {
                    //             Get.find<DashBoardController>()
                    //                 .getServicesDetails(
                    //                     e.redirectId.toString());
                    //           } else {
                    //             // TODO : Handle other types of banners link
                    //           }
                    //         } catch (e) {
                    //           debugPrint("onClick Error: $e");
                    //         }
                    //       },
                    //     ))
                    // .toList(),
                    ),
                Visibility(
                    visible:
                        ((controller.quickRepair ?? Services(data: [])).data ??
                                [])
                            .isNotEmpty,
                    child: SizedBox(
                      height: 20,
                    )),
                Visibility(
                  visible:
                      ((controller.quickRepair ?? Services(data: [])).data ?? [])
                          .isNotEmpty,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    padding: EdgeInsets.all(8),
                    child: HorizontalAnimatedList(
                      imageHeight: 177,
                      data: controller.quickRepair ?? Services(data: []),
                      heading: 'Quick Repairs',
                    ),
                  ),
                ),
                // TODO : Location widget is hidden
                // SizedBox(
                //   height: 10,
                // ),
                // CustomMapLocationWidget(),
                // SizedBox(
                //   height: 50,
                // ),
                // 🔥 Refer & Earn Card (LAST ITEM)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => ReferEarnScreen());
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xff227FA8), Color(0xff34A9C7)],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.card_giftcard, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Refer & Earn ₹150',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Invite friends & earn ₹150 when they book',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    });
  }
}
