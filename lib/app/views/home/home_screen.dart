import 'dart:developer';
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
  const HomeScreen({super.key});

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
      Get.find<DashBoardController>().loadHome();
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final controller = Get.find<DashBoardController>();
  //
  //     controller.getFeaturedCategories(
  //         limit: "6", offset: "1", isShowLoading: true);
  //     controller.getTopRated("10", "1", true);
  //     controller.getQuickRepair("10", "1", false);
  //     controller.getBanners();
  //     controller.homeSubCategoryList;
  // }

  Future<void> _onRefresh() async {
    await Get.find<DashBoardController>().loadHome(force: true);
  }

  // Future<void> _onRefresh() async {
  //   final controller = Get.find<DashBoardController>();
  //
  //   await Future.wait([
  //     controller.getFeaturedCategories(limit: "6", offset: "1"),
  //     controller.getTopRated("10", "1", true),
  //     controller.getQuickRepair("10", "1", false),
  //     controller.getBanners(),
  //   ]);
  //
  //   controller.update();
  // }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      final allCategories = controller.categoryList?.data ?? [];

      final pinnedCategories = allCategories
          .where((cat) => pinnedCategoryIds.contains(cat.id.toString()))
          .toList();

      log("ALL CATEGORIES COUNT: ${allCategories.length}");
      log("PINNED COUNT: ${pinnedCategories.length}");

      return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final shortest = MediaQuery.of(context).size.shortestSide;

            final isTablet = shortest >= 600;
            final isLargeTablet = shortest >= 900;

            final contentMaxWidth = isLargeTablet
                ? 760.0
                : isTablet
                    ? 620.0
                    : double.infinity;
            // final w = constraints.maxWidth;
            // final isTablet = w >= 600;
            // final isLargeTablet = w >= 900;
            //
            // // Content ko tablet pe center + max width
            // final contentMaxWidth = isLargeTablet
            //     ? 760.0
            //     : isTablet
            //     ? 620.0
            //     : double.infinity;

            // Padding responsive
            final horizontalPadding = isTablet ? 16.0 : 16.0;

            // Category item width dynamic (CategoryComponents me width pass hota hai)
            // Mobile: 3 columns, Tablet: 4 columns (approx feel)
            final categoryColumns = isTablet ? 4 : 3;
            final categoryItemWidth =
                (contentMaxWidth == double.infinity ? w : contentMaxWidth);
            final categoryWidth =
                (categoryItemWidth - (horizontalPadding * 2)) /
                        categoryColumns -
                    6;

            // Carousel height responsive
            final carouselHeight = isLargeTablet
                ? 260.0
                : isTablet
                    ? 230.0
                    : 200.0;

            // Recently viewed card width
            // Mobile: ~55% width, Tablet: ~38-42% width
            double recentlyCardFactor = isLargeTablet
                ? 0.34
                : isTablet
                    ? 0.42
                    : 0.55;

            // Placeholder grid height calculation
            final placeholderItemSize = categoryWidth;
            final placeholderHeight = (placeholderItemSize * 2) + 65;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      InkWell(
                        onTap: () async {
                          // final dash = Get.find<DashBoardController>();
                          //
                          // // Fetch data without showing loading
                          // await dash.getFeaturedCategories(
                          //   limit: "50",
                          //   offset: "1",
                          //   isShowLoading: false,
                          // );

                          // Switch to page 1 on the existing dashboard
                          DashboardScreen.globalKey.currentState?.setPage(1);
                        },
                        child: Image.asset(
                          'assets/images/instant_repairs.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: isTablet ? 18 : 15),

                      /// Heading Row
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  "All Services",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                // final dash = Get.find<DashBoardController>();
                                //
                                // // Fetch data without showing loading
                                // await dash.getFeaturedCategories(
                                //   limit: "50",
                                //   offset: "1",
                                //   isShowLoading: false,
                                // );

                                // Switch to page 1 on the existing dashboard
                                DashboardScreen.globalKey.currentState
                                    ?.setPage(1);
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
                          width: categoryWidth,
                          isShowSeeAll: true,
                        )
                      else
                        // Placeholder: 2 rows x 3/4 columns feel
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,vertical: 12),
                          child: SizedBox(
                            height: placeholderHeight,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: categoryColumns,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: categoryColumns * 2,
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [

                                      /// CONTAINER
                                      Container(
                                        height: 110,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      /// TEXT PLACEHOLDER
                                      Container(
                                        height: 10,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            ),
                          ),
                        ),

                      /// Our Features
                      Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding,
                          // top: 8,
                          right: horizontalPadding,
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Our Features",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // carousel slider images
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 18 : 14,
                          vertical: 12,
                        ),
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

                                    final dashController =
                                        Get.find<DashBoardController>();
                                    final allCategories =
                                        dashController.categoryList?.data ?? [];

                                    if (allCategories.isEmpty) {
                                      return const SizedBox();
                                    }

                                    /// Dynamic category mapping
                                    final category = allCategories[
                                        index % allCategories.length];

                                    return InkWell(
                                      onTap: () {
                                        log("CLICKED BANNER CATEGORY ID = ${category.id}");

                                        dashController
                                            .getCategoriesToSubCategories(
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
                                                      Colors.black
                                                          .withOpacity(0.55),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            /// ️ TEXT AREA
                                            const Positioned(
                                              left: 14,
                                              right: 14,
                                              bottom: 12,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Keeping same UI
                                                  // (No logic change)
                                                  // ignore: prefer_const_constructors
                                                  _ExploreChip(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  options: CarouselOptions(
                                    height: carouselHeight,
                                    autoPlay: true,
                                    autoPlayInterval:
                                        const Duration(seconds: 3),
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
                                  children: List.generate(staticBanners.length,
                                      (index) {
                                    final isActive = _currentIndex == index;

                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 10,
                          ),
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
                                      key: ValueKey(
                                          controller.topRated?.data?.length ??
                                              0), // rebuild fix
                                      imageHeight: isTablet ? 210 : 195,
                                      data: controller.topRated ??
                                          Services(data: []),
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

                      if ((controller.subCategoryModelListing?.data ?? [])
                          .isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: const Text(
                                "Services Viewed Recently",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: isTablet ? 200 : 180,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final cardWidth =
                                      constraints.maxWidth * recentlyCardFactor;

                                  return ListView.separated(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: horizontalPadding),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller
                                        .subCategoryModelListing!.data!.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 14),
                                    itemBuilder: (context, index) {
                                      final subCategory = controller
                                          .subCategoryModelListing!
                                          .data![index];

                                      final isSelected = controller
                                          .selectedSubCategories
                                          .contains(subCategory);

                                      return GestureDetector(
                                        onTap: () {
                                          controller.selectedSubCategories
                                            ..clear()
                                            ..add(subCategory);

                                          controller.getCategoriesToServices(
                                            id: subCategory.id.toString(),
                                            limit: '10',
                                            offset: "1",
                                            isLoading: true,
                                          );

                                          controller.update();
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          width: cardWidth,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF207FA7)
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 10,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            child: Stack(
                                              children: [
                                                /// Image
                                                Positioned.fill(
                                                  child: Image.network(
                                                    subCategory
                                                            .thumbnailFullPath ??
                                                        "",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),

                                                /// Gradient overlay
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end: Alignment.center,
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(0.6),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                /// 🔹 Title on Image
                                                Positioned(
                                                  bottom: 12,
                                                  left: 12,
                                                  right: 12,
                                                  child: Text(
                                                    subCategory.name ?? "",
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          isTablet ? 16 : 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
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
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 10,
                          ),
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
                                  imageHeight: isTablet ? 190 : 177,
                                  data: controller.quickRepair ??
                                      Services(data: []),
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
                      //       ...
                      //     ),
                      //   ),
                      // ),

                      /// Footer (Full width feel even when centered)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 0 : 0,
                        ),
                        child: buildDoFixFooter(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

/// Small extracted widget only for const-positioned area
/// (No logic change; purely UI)
class _ExploreChip extends StatelessWidget {
  const _ExploreChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    );
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
