import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:do_fix/app/widgets/history_list_item.dart';
import 'package:do_fix/data/api/api.dart';
import 'package:do_fix/model/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/booking_controller.dart';
import '../../model/service_model.dart';
import '../../widgets/custom_image_viewer.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class ServiceContainer extends StatelessWidget {
  final ServiceModel? serviceModel;
  final bool? isButtonShow;
  final bool showReviews;

  const ServiceContainer({
    super.key,
    this.serviceModel,
    this.isButtonShow = false,
    this.showReviews = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 700;
    final bool isSmallPhone = screenWidth < 360;

    // return TweenAnimationBuilder<double>(
    //   duration: const Duration(milliseconds: 500),
    //   tween: Tween(begin: 0.0, end: 1.0),
    //   curve: Curves.easeOutBack,
    //   builder: (context, value, child) {
    //     return Transform.scale(
    //       scale: value,
    //       child: Opacity(
    //         opacity: value.clamp(0.0, 1.0),
    //         child: child,
    //       ),
    //     );
    //   },
    //   child: Material(
    //     color: Colors.transparent,
    //     child: Container(
    //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: BorderRadius.circular(24),
    //         boxShadow: [
    //           BoxShadow(
    //             color: Colors.black.withOpacity(0.08),
    //             blurRadius: 25,
    //             offset: const Offset(0, 12),
    //           ),
    //           BoxShadow(
    //             color: Colors.black.withOpacity(0.04),
    //             blurRadius: 8,
    //             offset: const Offset(0, 4),
    //           ),
    //         ],
    //       ),
    //       child: ClipRRect(
    //         borderRadius: BorderRadius.circular(15),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Stack(
    //               children: [
    //                 SizedBox(
    //                   width: double.infinity,
    //                   height: MediaQuery.of(context).size.height * 0.23,
    //                   child: CustomNetworkImageWidget(
    //                     image: serviceModel?.thumbnailFullPath ?? "",
    //                     fit: BoxFit.cover,
    //                     width: double.infinity,
    //                     height: double.infinity,
    //                     imagePadding: 0,
    //                   ),
    //                 ),
    //                 Container(
    //                   height: MediaQuery.of(context).size.height * 0.23,
    //                   decoration: BoxDecoration(
    //                     gradient: LinearGradient(
    //                       begin: Alignment.topCenter,
    //                       end: Alignment.bottomCenter,
    //                       colors: [
    //                         Colors.transparent,
    //                         Colors.black.withOpacity(0.35),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //                 Positioned(
    //                   bottom: 16,
    //                   left: 16,
    //                   right: 16,
    //                   child: Text(
    //                     serviceModel?.name ?? "",
    //                     maxLines: 2,
    //                     overflow: TextOverflow.ellipsis,
    //                     style: const TextStyle(
    //                       fontSize: 20,
    //                       fontWeight: FontWeight.w700,
    //                       color: Colors.white,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.all(18),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Row(
    //                     children: [
    //                       Icon(Icons.category_rounded,
    //                           size: 16,
    //                           color: Colors.grey.shade600),
    //                       const SizedBox(width: 6),
    //                       Expanded(
    //                         child: Text(
    //                           serviceModel?.category?.name ?? "N/A",
    //                           maxLines: 1,
    //                           overflow: TextOverflow.ellipsis,
    //                           style: TextStyle(
    //                             fontSize: 14,
    //                             fontWeight: FontWeight.w500,
    //                             color: Colors.grey.shade700,
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   const SizedBox(height: 12),
    //                   Container(
    //                     height: 1,
    //                     width: double.infinity,
    //                     color: Colors.grey.shade200,
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    final String categoryName = serviceModel?.category?.name ?? "";
    final String subCategoryName = serviceModel?.subCategory?.name ?? "";
    final bool hasCategory = categoryName.isNotEmpty;
    final bool hasSubCategory = subCategoryName.isNotEmpty;
    final bool hasReviewChip = showReviews;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 0 : 0,
          vertical: 0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF207FA7).withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE SECTION
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: isTablet ? 2.5 : 2.0,
                    child: CustomNetworkImageWidget(
                      image: serviceModel?.thumbnailFullPath ?? "",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      imagePadding: 0,
                    ),
                  ),

                  /// Top soft overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.06),
                            Colors.transparent,
                            Colors.black.withOpacity(0.26),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Name + badge
                  Positioned(
                    left: isTablet ? 20 : 14,
                    right: isTablet ? 20 : 14,
                    bottom: isTablet ? 18 : 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasSubCategory)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              subCategoryName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isSmallPhone ? 10.5 : 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                        if (hasSubCategory) const SizedBox(height: 8),
                        Text(
                          serviceModel?.name ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.25,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// CONTENT SECTION
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 20 : 14,
                  isTablet ? 14 : 12,
                  isTablet ? 20 : 14,
                  isTablet ? 16 : 13,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Category left + Rating right
                    if (hasCategory || hasReviewChip)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: hasCategory
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_rounded,
                                  size: 15,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    categoryName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isTablet ? 13.5 : 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : const SizedBox.shrink(),
                          ),
                          if (hasReviewChip)
                            _buildInfoChip(
                              icon: Icons.star_rounded,
                              label:
                              "${(serviceModel?.avgRating ?? 0.0).toStringAsFixed(1)} (${serviceModel?.ratingCount ?? 0})",
                            ),
                        ],
                      ),

                    if (hasCategory || hasReviewChip)
                      const SizedBox(height: 12),

                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                    ),
                    //
                    // if ((serviceModel?.description ?? "").trim().isNotEmpty) ...[
                    //   const SizedBox(height: 14),
                    //   Text(
                    //     serviceModel?.description ?? "",
                    //     maxLines: 3,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: TextStyle(
                    //       fontSize: isTablet ? 14 : 12.5,
                    //       height: 1.55,
                    //       color: Colors.black.withOpacity(0.66),
                    //       fontWeight: FontWeight.w400,
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF207FA7).withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF207FA7).withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF207FA7),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingDialog {
  static void showLoading({String? message}) {
    Get.dialog(
      const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  //
  // static void hideLoading() {
  //   Get.back();
  // }
  static void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  }
}

class BookingContainer extends StatefulWidget {
  final Booking? booking;
  final bool isLoading;

  const BookingContainer({
    super.key,
    this.booking,
    this.isLoading=false
  });

  @override
  State<BookingContainer> createState() => _BookingContainerState();
}

class _BookingContainerState extends State<BookingContainer> {
  final isButtonShow = false;
  dynamic filePaths = "";
  double progress = 0.0;
  bool isDownloading = false;
  final bookingController = Get.find<BookingController>();

  Future<void> downloadFile(String url, String fileName) async {
    bool isGranted = await Permission.storage.isGranted;

    if (!isGranted) {
      bool userGranted = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Storage Permission Required"),
            content: Text(
              "This app needs storage access to save the file to the Downloads folder. "
                  "If you deny permission, the file will be saved internally, and you can access it only within the app. "
                  "To grant permission manually, go to Settings > Apps > This App > Permissions.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("Deny"),
              ),
              TextButton(
                onPressed: () async {
                  await Permission.storage.request();
                  Navigator.of(context).pop(true);
                },
                child: Text("Allow"),
              ),
            ],
          );
        },
      );

      if (userGranted) {
        await Permission.manageExternalStorage.request();
        await Permission.storage.request();
        isGranted = await Permission.storage.isGranted;
      }
    }

    setState(() {
      progress = 0.0;
      isDownloading = true;
    });
    LoadingDialog.showLoading(message: "Completed: $progress");

    Directory? downloadsDir;
    if (Platform.isAndroid && isGranted) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else {
      downloadsDir = await getApplicationSupportDirectory();
    }

    final filePath = "${downloadsDir.path}/$fileName";

    Dio dio = Dio();
    ApiClient apiClient = Get.find<ApiClient>();
    log("ApiClient: ${apiClient.mainHeaders["Authorization"]}");
    try {
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = received / total;
            });
          }
        },
      );

      setState(() {
        isDownloading = false;
      });

      filePaths = filePath;
      LoadingDialog.hideLoading();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Download Complete"),
            content: Text("The file has been downloaded successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  OpenFile.open(filePath);
                },
                child: Text("Open File"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      print("Download failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: HistoryListItem(booking: widget.booking),
      ),
    );
  }
}

Future<void> _launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  await launchUrl(url, mode: LaunchMode.externalApplication);
}