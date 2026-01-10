import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../model/category_model.dart';
import '../../../utils/images.dart';
import '../../../widgets/custom_image_viewer.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_containers.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/sizeboxes.dart';
import '../../../utils/styles.dart';
import '../../../utils/theme.dart';
import '../home/component/category_components.dart';

class ServiceScreens extends StatefulWidget {
  const ServiceScreens({super.key});

  @override
  State<ServiceScreens> createState() => _ServiceScreensState();
}

class _ServiceScreensState extends State<ServiceScreens> {
  final ScrollController _scrollController = ScrollController();
  int currentOffset = 1; // Pagination offset
  bool isLoading = false; // To prevent multiple API calls

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DashBoardController>().getData("10", currentOffset.toString());
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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
    await controller.getData("10", currentOffset.toString());

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DashBoardController>(
        builder: (controller) {
          return Scaffold(
            body:  CategoryComponents(categoryList: controller.categoryList ?? CategoryModel(data: []),width: MediaQuery.of(context).size.width / 3 - 18, isShowSeeAll: false,),


            // Column(
            //   children: [
            //     Visibility(
            //       visible: (controller.categoryList?.data ?? []).isNotEmpty,
            //       child: Padding(
            //         padding: const EdgeInsets.only(left: 7.0,top: 10, right: 2),
            //         child: SizedBox(
            //           width: double.infinity,
            //           height: 123,
            //           child: Wrap(
            //             alignment: WrapAlignment.start,
            //             spacing: 13.0,
            //             runSpacing: 10.0,
            //             children: List.generate(
            //               (controller.categoryList?.data ?? []).length,
            //                   (i) => SizedBox(
            //                 width: MediaQuery.of(context).size.width / 3 - 15,
            //                 height: 150,
            //                 child: GestureDetector(
            //                   onTap: () {
            //
            //                     debugPrint("data:==");
            //
            //                     Get.find<DashBoardController>()
            //                         .getCategoriesToSubCategories(
            //                         id: (controller.categoryList?.data ?? [])[i]
            //                             .id.toString(),
            //                         limit: '10',
            //                         offset: "1");
            //                   },
            //                     child: CustomDecoratedContainer(
            //
            //                     borderColor: Theme.of(context).hintColor,
            //
            //                     child: Column(
            //                       mainAxisSize: MainAxisSize.min,
            //                       children: [
            //                         CustomNetworkImageWidget(
            //                           imagePadding: 0,
            //                           width: Get.size.width,
            //                           height: 90, image: controller.categoryList?.data?[i].imageFullPath ?? "",
            //                         ),
            //                         sizedBox10(),
            //                         Text(
            //                           controller.categoryList?.data?[i].name ?? "",
            //                           maxLines: 2,
            //                           overflow: TextOverflow.ellipsis,
            //                           textAlign: TextAlign.center,
            //                           style: albertSansRegular.copyWith(
            //                             fontSize: Dimensions.fontSize12,
            //                             color: Colors.black,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //     Visibility(
            //       visible: isLoading,
            //       child: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: CircularProgressIndicator(),
            //       ),
            //     ),
            //   ],
            // ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _loadNextPageManually,
      //   child: Icon(Icons.arrow_downward),
      //   tooltip: "Load Next Page",
      // ),
    );
  }
}
