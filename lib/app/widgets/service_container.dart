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
    return Material(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(10), // Added padding for better spacing
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomNetworkImageWidget(
                    image: serviceModel?.thumbnailFullPath ?? "",
                    height: 91.0, // Fixed height instead of double.infinity
                    width: 91.0,
                  ),
                  const SizedBox(width: 10),
                  // Add spacing between image and text
                  Flexible(
                    // Prevents Row layout error
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      mainAxisSize: MainAxisSize.min,
                      // Avoids unnecessary expansion
                      children: [
                        Text(
                          serviceModel?.name ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        // const SizedBox(height: 5),
                        // Visibility(
                        //   visible: serviceModel?.ratingCount != 0,
                        //   child: Row(
                        //     children: [
                        //       Text(
                        //         serviceModel?.ratingCount?.toString() ?? "0",
                        //         style: const TextStyle(fontSize: 14),
                        //       ),
                        //       const SizedBox(width: 5),
                        //       // const Icon(Icons.star,
                        //       //     color: Colors.yellow, size: 13),
                        //       Text(
                        //         serviceModel?.ratingCount?.toString() == "1"
                        //             ? "Review"
                        //             : "Reviews",
                        //         style: const TextStyle(fontSize: 14),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 5),
                        Text(
                          serviceModel?.category?.name ?? "N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black.withOpacity(0.50)),
                        ),
                        const SizedBox(height: 8),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       "₹ ${(double.tryParse(serviceModel?.minBiddingPrice ?? "0")?.toInt() ?? 0)}",
                        //       style: const TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.w700,
                        //         color: Color(0xFF207FA7),
                        //       ),
                        //     ),
                        //     if (isButtonShow ?? false)
                        //       CustomButtonWidget(
                        //         height: 30,
                        //         width: 80,
                        //         onPressed: () {
                        //           ShowAddToCartSheet(
                        //             context,
                        //             serviceModel!,
                        //           );
                        //         },
                        //         buttonText: "Add",
                        //         transparent: false,
                        //         fontSize: 12,
                        //         textColor: Colors.white,
                        //         fontWeight: FontWeight.w600,
                        //         borderSideColor: const Color(0xFF207FA7),
                        //       ),
                        //   ],
                        // ),
                        // const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  static void hideLoading() {
    Get.back();
  }
}

class BookingContainer extends StatefulWidget {
  final Booking? booking;

  const BookingContainer({
    super.key,
    this.booking,
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
                "To grant permission manually, go to Settings > Apps > This App > Permissions."),
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
