import 'package:do_fix/widgets/custom_dot_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../home/component/category_components.dart';
import '../../../model/all_category_model.dart';
import 'component/service_category_components.dart';

class ServiceScreens extends StatefulWidget {
  const ServiceScreens({super.key});

  @override
  State<ServiceScreens> createState() => _ServiceScreensState();
}

class _ServiceScreensState extends State<ServiceScreens> {
  late ScrollController _scrollController;
  int currentOffset = 1; // Pagination offset
  bool isLoading = false; // To prevent multiple API calls
  final DashBoardController dashboard = Get.find<DashBoardController>();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Fetch all categories
      await dashboard.fetchAllCategories(limit: "50", offset: "1");

      // Fetch first page of services
      await dashboard.getData(10, 1);
    });
  }

  Future<void> onRefresh() async {
    currentOffset = 1;
    await dashboard.getData(10, currentOffset);
    await dashboard.fetchAllCategories(limit: "50", offset: "1");
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // _loadMoreData();
    }
  }

  // Future<void> _loadMoreData() async {
  //   if (isLoading) return;
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   int previousOffset = currentOffset;
  //   currentOffset += 1;
  //
  //   await dashboard.getData(10, currentOffset);
  //
  //   if ((dashboard.servicesListing?.data ?? []).isEmpty) {
  //     // No more data, revert
  //     setState(() {
  //       currentOffset = previousOffset;
  //     });
  //
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("No more services available"),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //       _scrollController.animateTo(
  //         _scrollController.position.maxScrollExtent - 200,
  //         duration: const Duration(milliseconds: 500),
  //         curve: Curves.easeOut,
  //       );
  //     });
  //   }
  //
  //   setState(() {
  //     isLoading = false;
  //   });
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
      body: Obx(() {
        // Show loader while fetching
        if (dashboard.isAllCategoryLoading.value) {
          return const Center(child: DotWaveLoader());
        }

        // Empty state
        if (dashboard.allCategoryModel?.content?.data == null ||
            dashboard.allCategoryModel!.content!.data!.isEmpty) {
          return const Center(
            child: Text("No categories found"),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ServiceCategoryComponents(
              allCategoryModel: dashboard.allCategoryModel,
              width: MediaQuery.of(context).size.width / 3 - 18,
              isShowSeeAll: true,
            ),
          ),
        );
      }),
    );
  }
}