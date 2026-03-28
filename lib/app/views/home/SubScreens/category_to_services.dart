import 'package:do_fix/app/widgets/custom_floating_cart_widget.dart';
import 'package:do_fix/model/service_model.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/widgets/custom_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/dashboard_controller.dart';
import '../../../../model/category_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../../utils/styles.dart';
import '../../../widgets/custom_appbar.dart';
import '../../services/service_details_screen.dart';

class CategoryToServices extends StatelessWidget {
  const CategoryToServices({super.key});

  @override
  Widget build(BuildContext context) {
    var categoryDetails = CategoryModel().data;
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
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              final dash = Get.find<DashBoardController>();

              if (dash.selectedSubCategories.isNotEmpty) {
                await dash.getCategoriesToServices(
                  id: dash.selectedSubCategories[0].id.toString(),
                  limit: '50',
                  offset: "1",
                  isLoading: false,
                );
              }

              dash.update(['cart_total']);
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Selected Sub-category Name
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            controller.selectedCategoryName.isNotEmpty
                                ? controller.selectedCategoryName
                                : "Category",
                            style: albertSansRegular.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // Sub-categories Grid
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 16),
                        width: Get.size.width,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ((controller.subCategoryModelListing ??
                                          SubCategoryModel(data: []))
                                      .data ??
                                  [])
                              .map((subCategory) {
                            return SizedBox(
                              width: (Get.size.width - 16 * 2 - 10 * 2) / 3,
                              child: GestureDetector(
                                onTap: () {
                                  if (controller.isServiceListingLoading)
                                    return;

                                  print(
                                      "Starting load for: ${subCategory.name}");

                                  controller.selectedSubCategories.clear();
                                  controller.selectedSubCategories
                                      .add(subCategory);

                                  controller.getCategoriesToServices(
                                    id: subCategory.id.toString(),
                                    limit: '50',
                                    offset: "1",
                                    isLoading: true,
                                  );
                                },
                                // ... rest same
                                // onTap: () {
                                //   controller.isServiceListingLoading = true;
                                //   controller.update();
                                //
                                //   controller.getCategoriesToServices(
                                //     id: subCategory.id.toString(),
                                //     limit: '50',
                                //     offset: "1",
                                //     isLoading: true,
                                //   );
                                //   controller.selectedSubCategories.clear();
                                //   controller.selectedSubCategories
                                //       .add(subCategory);
                                // },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 3,
                                          color: controller
                                                  .selectedSubCategories
                                                  .contains(subCategory)
                                              ? const Color(0xFF207FA7)
                                              : Colors.white,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: Image.network(
                                          subCategory.thumbnailFullPath ?? "",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subCategory.name ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: albertSansRegular.copyWith(
                                        fontSize: Dimensions.fontSize12,
                                        color: controller.selectedSubCategories
                                                .contains(subCategory)
                                            ? const Color(0xFF207FA7)
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      sizedBox10(),
                      // bathroom
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        width: Get.size.width,
                        height:
                            controller.isServiceListingLoading ? 250.0 : null,
                        child: Builder(
                          builder: (context) {
                            final services =
                                (controller.categoriesToServiceListing ??
                                            Services(data: []))
                                        .data ??
                                    [];
                            print("DEBUG START");
                            print(" Total Services: ${services.length}");
                            if (services.isNotEmpty) {
                              final firstService = services.first;
                              print(
                                  "🏷 First Service Name: ${firstService.name}");
                              print(
                                  " startingPrice: '${firstService.startingPrice}' (${firstService.startingPrice.runtimeType})");
                              print(
                                  " servicCost: '${firstService.serviceCost}' (${firstService.serviceCost.runtimeType})");
                              print(" All fields: ${firstService.toJson()}");
                            }
                            print(" DEBUG END ");

                            // if (controller.isServiceListingLoading) {
                            //   return const Center(
                            //     child: Padding(
                            //       padding: EdgeInsets.all(40.0),
                            //       child: CircularProgressIndicator(
                            //         valueColor: AlwaysStoppedAnimation<Color>(
                            //             Color(0xFF207FA7)),
                            //       ),
                            //     ),
                            //   );
                            // }

                            final totalServices = services.length;

                            return services.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// Total Services Count Badge
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 15),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF207FA7)
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                            color: const Color(0xFF207FA7)
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        child: Text(
                                          "$totalServices Services Available",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF207FA7),
                                          ),
                                        ),
                                      ),

                                      /// Services List - COMPLETE CODE
                                      ...List.generate(
                                        services.length,
                                        (i) {
                                          final service = services[i];

                                          return GestureDetector(
                                            onTap: () {
                                              Get.find<DashBoardController>()
                                                  .getServicesDetails(
                                                      service.id ?? "");
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.white,
                                                          Colors.grey.shade50,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade200,
                                                        width: 1.2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.08),
                                                          blurRadius: 20,
                                                          spreadRadius: 2,
                                                          offset: const Offset(
                                                              0, 10),
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.04),
                                                          blurRadius: 8,
                                                          spreadRadius: 1,
                                                          offset: const Offset(
                                                              0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        /// Stylish Image
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.12),
                                                                blurRadius: 12,
                                                                offset:
                                                                    const Offset(
                                                                        0, 6),
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            child:
                                                                CustomNetworkImageWidget(
                                                              fit: BoxFit.cover,
                                                              imagePadding: 0,
                                                              width: constraints
                                                                      .maxWidth *
                                                                  0.28,
                                                              height: 110,
                                                              image: service
                                                                      .thumbnailFullPath ??
                                                                  "",
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                            width: 16),

                                                        /// Right Side Content
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              /// Service Name
                                                              Text(
                                                                service.name ??
                                                                    "",
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    albertSansRegular
                                                                        .copyWith(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                              // STARTING PRICE
                                                              if (service.startingPrice !=
                                                                      null &&
                                                                  service.startingPrice! >
                                                                      0) ...[
                                                                const SizedBox(
                                                                    height: 8),
                                                                // Fixed
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        const Color(0xFF207FA7)
                                                                            .withOpacity(0.15),
                                                                        const Color(0xFF207FA7)
                                                                            .withOpacity(0.05),
                                                                      ],
                                                                      begin: Alignment
                                                                          .centerLeft,
                                                                      end: Alignment
                                                                          .centerRight,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color(
                                                                              0xFF207FA7)
                                                                          .withOpacity(
                                                                              0.3),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .trending_up_rounded,
                                                                        size:
                                                                            14,
                                                                        color: const Color(
                                                                            0xFF207FA7),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        "₹${service.startingPrice!.toStringAsFixed(0)}",
                                                                        //  Safe access
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          color:
                                                                              Color(0xFF207FA7),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        " onwards",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              const Color(0xFF207FA7).withOpacity(0.8),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                              const SizedBox(
                                                                  height: 10),

                                                              /// Rating Row
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .star_rounded,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .amber
                                                                        .shade600,
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                    service.avgRating
                                                                            ?.toStringAsFixed(1) ??
                                                                        "0.0",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                    "(${service.ratingCount ?? 0})",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),

                                                              if ((service.variations
                                                                          ?.length ??
                                                                      0) >
                                                                  0)
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              6),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                            0xFF91A4AF)
                                                                        .withOpacity(
                                                                            0.08),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color(
                                                                              0xFF217A9F)
                                                                          .withOpacity(
                                                                              0.2),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    "${service.variations?.length ?? 0} Options Available",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Color(
                                                                          0xFF207FA7),
                                                                    ),
                                                                  ),
                                                                ),

                                                              const SizedBox(
                                                                  height: 4),

                                                              /// CTA Row
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "View Details",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: const Color(
                                                                          0xFF207FA7),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),

                                                                  /// Circular Arrow
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color(
                                                                              0xFF207FA7)
                                                                          .withOpacity(
                                                                              0.12),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .arrow_forward_ios_rounded,
                                                                      size: 14,
                                                                      color: Color(
                                                                          0xFF207FA7),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                      ),
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
        ),
      );
    });
  }
}
