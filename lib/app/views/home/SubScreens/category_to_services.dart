import 'package:do_fix/app/views/home/component/variations_new_card.dart';
import 'package:do_fix/app/widgets/custom_floating_cart_widget.dart';
import 'package:do_fix/model/service_model.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/widgets/custom_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/dashboard_controller.dart';
import '../../../../utils/dimensions.dart';
import '../../../../utils/styles.dart';
import '../../../widgets/custom_appbar.dart';

class CategoryToServices extends StatelessWidget {
  const CategoryToServices({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
          appBar: CustomAppBar(
            title: "Services",
            isBackButtonExist: true,
            isSearchButtonExist: false,
            onBackPressed: () {
              Get.back();
            },
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0,
                            color: Colors.white,
                            // color:Color(0xFF207FA7)
                          ),
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      width: Get.size.width,
                      height: 150,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            debugPrint(((controller.subCategoryModelListing ??
                                                SubCategoryModel(data: []))
                                            .data ??
                                        [])[i]
                                    .thumbnailFullPath ??
                                "");
                            return GestureDetector(
                              onTap: () {
                                controller.getCategoriesToServices(
                                    id: ((controller.subCategoryModelListing ??
                                                    SubCategoryModel(data: []))
                                                .data ??
                                            [])[i]
                                        .id
                                        .toString(),
                                    limit: '10',
                                    offset: "1",
                                    isLoading: true);
                                controller.selectedSubCategories.clear();
                                controller.selectedSubCategories.add(
                                    ((controller.subCategoryModelListing ??
                                                SubCategoryModel(data: []))
                                            .data ??
                                        [])[i]);
                              },
                              child: Container(
                                width: 106,
                                height: 114,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Container(
                                        width: 106,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 3,
                                              color: controller
                                                      .selectedSubCategories
                                                      .contains(((controller
                                                                      .subCategoryModelListing ??
                                                                  SubCategoryModel(
                                                                      data: []))
                                                              .data ??
                                                          [])[i])
                                                  ? Color(0xFF207FA7)
                                                  : Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            ((controller.subCategoryModelListing ??
                                                                SubCategoryModel(
                                                                    data: []))
                                                            .data ??
                                                        [])[i]
                                                    .thumbnailFullPath ??
                                                "",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        ((controller.subCategoryModelListing ??
                                                            SubCategoryModel(
                                                                data: []))
                                                        .data ??
                                                    [])[i]
                                                .name ??
                                            "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: albertSansRegular.copyWith(
                                            fontSize: Dimensions.fontSize12,
                                            decoration: TextDecoration.none,
                                            color: controller
                                                    .selectedSubCategories
                                                    .contains(((controller
                                                                    .subCategoryModelListing ??
                                                                SubCategoryModel(
                                                                    data: []))
                                                            .data ??
                                                        [])[i])
                                                ? Color(0xFF207FA7)
                                                : Colors.grey),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, i) {
                            return SizedBox(
                              width: 10,
                            );
                          },
                          itemCount: ((controller.subCategoryModelListing ??
                                          SubCategoryModel(data: []))
                                      .data ??
                                  [])
                              .length),
                    ),
                    // SelectableButtonList(options: ((controller.subCategoryModelListing ?? SubCategoryModel(data: [])).data ?? []).map((looking) => looking.name).toList(), elementsPerRow: 0, onTap: (String ) {  }, buttonWidth: 87,buttonHeight: 89,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22.0),
                      child: Row(
                        children: [
                          Text(
                            controller.selectedSubCategories.isNotEmpty
                                ? "${controller.selectedSubCategories[0].name} Services"
                                : "Services",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: Get.size.width,
                      // height: Get.size.height,
                      child: ((controller.categoriesToServiceListing ??
                                          Services(data: []))
                                      .data ??
                                  [])
                              .isNotEmpty
                          ? SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 10.0, // Horizontal spacing
                                runSpacing: 8.0, // Vertical spacing
                                children: List.generate(
                                    ((controller.categoriesToServiceListing ??
                                                    Services(data: []))
                                                .data ??
                                            [])
                                        .length, (i) {
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3 -
                                            20,
                                    height: 115,
                                    child: GestureDetector(
                                      onTap: () {
                                        ServiceModel serviceModel =
                                            ((controller.categoriesToServiceListing ??
                                                        Services(data: []))
                                                    .data ??
                                                [])[i];

                                        Get.find<DashBoardController>()
                                            .getServicesDetails(
                                                serviceModel.id ?? "");
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          sizedBox10(),
                                          CustomNetworkImageWidget(
                                            fit: BoxFit.cover,
                                            imagePadding: 0,
                                            width: 90,
                                            height: 70,
                                            image:
                                                (controller.categoriesToServiceListing
                                                                ?.data ??
                                                            [])[i]
                                                        .thumbnailFullPath ??
                                                    "",
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                            ),
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              controller
                                                      .categoriesToServiceListing
                                                      ?.data?[i]
                                                      .name ??
                                                  "",
                                              maxLines: 2,
                                              style: albertSansRegular.copyWith(
                                                fontSize: Dimensions.fontSize10,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w300,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 150,
                                ),
                                Text(
                                  // "No Service Available",
                                  "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: albertSansRegular.copyWith(
                                      fontSize: Dimensions.fontSize12,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                            "Popular Service",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: Get.size.width,
                      child: ((controller.categoriesToServiceListing ??
                                          Services(data: []))
                                      .data ??
                                  [])
                              .isNotEmpty
                          ? SizedBox(
                              width: double.infinity,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    ((controller.categoriesToServiceListing ??
                                                    Services(data: []))
                                                .data ??
                                            [])
                                        .length,
                                separatorBuilder: (context, i) =>
                                    SizedBox(height: 0),
                                itemBuilder: (context, i) {
                                  final service =
                                      ((controller.categoriesToServiceListing ??
                                                  Services(data: []))
                                              .data ??
                                          [])[i];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (service.variations != null &&
                                            service.variations!.isNotEmpty) ...[
                                          ...service.variations!
                                              .map((variation) =>
                                                  VariationsNewCard(
                                                    serviceVariationName:
                                                        variation.variant,
                                                    serviceRatings: service
                                                            .avgRating
                                                            ?.toStringAsFixed(
                                                                1) ??
                                                        "0.0",
                                                    serviceReviewCount: service
                                                            .ratingCount
                                                            ?.toString() ??
                                                        "0",
                                                    serviceMrpPrice:
                                                        (variation.mrpPrice)
                                                            .toInt()
                                                            .toString(),
                                                    serviceDiscountedPrice:
                                                        variation.price
                                                            .toInt()
                                                            .toString(),
                                                    serviceTimeDuration: (variation
                                                                    .durationHour !=
                                                                "0" &&
                                                            variation
                                                                    .durationMinute !=
                                                                "0" &&
                                                            variation
                                                                    .durationHour !=
                                                                null &&
                                                            variation
                                                                    .durationMinute !=
                                                                null)
                                                        ? "${variation.durationHour}:${variation.durationMinute}"
                                                        : "",
                                                    serviceDescription: (variation
                                                                    .varDescription !=
                                                                "0" &&
                                                            variation
                                                                    .varDescription !=
                                                                null)
                                                        ? variation
                                                            .varDescription
                                                        : service
                                                                .shortDescription ??
                                                            "Quality service provided by professionals",
                                                    variantKey:
                                                        variation.variantKey,
                                                    serviceModel: service,
                                                  ))
                                              .toList(),
                                          // SizedBox(height: 15),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  "No services available",
                                  style: albertSansRegular.copyWith(
                                    fontSize: Dimensions.fontSize14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    // Add padding at the bottom for the floating cart
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: GetBuilder<DashBoardController>(
                  id: 'cart_total',
                  builder: (controller) {
                    // Calculate total amount and item count
                    double totalAmount = 0;
                    int itemCount = 0;
                    if (controller.cartModel.content?.cart?.data != null) {
                      itemCount =
                          controller.cartModel.content!.cart!.data!.length;
                      for (var item
                          in controller.cartModel.content!.cart!.data!) {
                        totalAmount += (item.totalCost ?? 0);
                      }
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: CustomFloatingCartWidget(
                        totalAmount: totalAmount,
                        itemCount: itemCount,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
