import 'dart:convert';
import 'dart:async';
import 'package:do_fix/app/views/services/service_details_screen.dart';
import 'package:do_fix/app/widgets/custom_appbar.dart';
import 'package:do_fix/app/widgets/service_container.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  double minPrice = 0;
  double maxPrice = 50000;
  String rating = "";
  String sortBy = "a_to_z";
  String sortByType = "default";

  List<dynamic> searchResults = [];
  bool isLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSearchResults() async {
    setState(() {
      isLoading = true;
    });
    Get.find<DashBoardController>().getSearchList(
      {
        "string": searchController.text,
        "min_price": minPrice.toString(),
        "max_price": maxPrice.toString(),
        "rating": rating,
        "sort_by": sortBy,
        "sort_by_type": sortByType,
      },
    );
    setState(() {
      isLoading = false;
    });
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      fetchSearchResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
      builder: (controller) {
        return SafeArea(
          top: false,
          child: Scaffold(
            appBar: CustomAppBar(
              title: "Search Service",
              isBackButtonExist: true,
              isSearchButtonExist: false,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    focusNode: _searchFocusNode,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      labelText: "Search",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  controller.isLoginLoading
                      ? CircularProgressIndicator()
                      : Obx(() {
                          return Get.find<DashBoardController>()
                                      .serviceModelSearchList
                                      .length >
                                  0
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: Get.find<DashBoardController>()
                                        .serviceModelSearchList
                                        .length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          Get.find<DashBoardController>()
                                              .serviceModelSearchList[index];
                                      return InkWell(
                                        onTap: () {
                                          Get.find<DashBoardController>()
                                              .serviceModel = item;
                                          Get.find<DashBoardController>()
                                              .update();
                                          Future.delayed(
                                              Duration(milliseconds: 1));
                                          Get.to(() => ServiceDetails());
                                        },
                                        child: ServiceContainer(
                                          serviceModel: item,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text("No service found."),
                                );
                        }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
