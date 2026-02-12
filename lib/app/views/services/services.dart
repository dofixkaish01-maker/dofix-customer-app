import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../model/category_model.dart';
import '../home/component/category_components.dart';
class ServiceScreens extends StatefulWidget {
  const ServiceScreens({super.key});

  @override
  State<ServiceScreens> createState() => _ServiceScreensState();
}

class _ServiceScreensState extends State<ServiceScreens> {
  late ScrollController _scrollController = ScrollController();
  int currentOffset = 1; // Pagination offset
  bool isLoading = false; // To prevent multiple API calls
  final DashBoardController dashboard = Get.find<DashBoardController>();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dashboardController = Get.find<DashBoardController>();

      // Load all categories for ServiceScreens
      await dashboardController.getFeaturedCategories(
        limit: "50", // Fetch all
        offset: "1",
        forDashboard: false,
      );

      // Fetch first page of services
      await dashboardController.getData(10, 1);
    });
  }


  Future<void> onRefresh() async {
    currentOffset = 1;
    await Get.find<DashBoardController>()
        .getData(10, currentOffset);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    int previousOffset = currentOffset;
    currentOffset += 1;

    final controller = Get.find<DashBoardController>();
    await controller.getData(10, currentOffset);

    if ((controller.servicesListing?.data ?? []).isEmpty) {
      // No more data, revert to previous offset
      setState(() {
        currentOffset = previousOffset;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No more services available"),
            duration: Duration(seconds: 2),
          ),
        );
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent - 200,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // void _loadNextPageManually() async {
  //
  //   int previousOffset = currentOffset;
  //   currentOffset += 1;
  //
  //   final controller = Get.find<DashBoardController>();
  //   await controller.getData("12", currentOffset.toString());
  //
  //   if ((controller.categoryList?.data ?? []).isEmpty) {
  //     setState(() {
  //       currentOffset = 1;
  //     });
  //     await controller.getData("12", currentOffset.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("No more services available"),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  //
  // }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DashBoardController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              await controller.getFeaturedCategories(
                  limit: "50", offset: "1", forDashboard: false);
              await controller.getData(10, 1);
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: CategoryComponents(
                categoryList: controller.allCategories ??
                    CategoryModel(data: []),
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 3 - 18,
                isShowSeeAll: true,
              ),
            ),
          );
        },
      ),
    );
  }
}