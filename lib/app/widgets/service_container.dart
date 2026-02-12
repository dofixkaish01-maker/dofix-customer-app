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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.95, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),

            // 🔥 Premium Layered Shadow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔥 IMAGE SECTION WITH GRADIENT OVERLAY
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.23,
                      child: CustomNetworkImageWidget(
                        image: serviceModel?.thumbnailFullPath ?? "",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        imagePadding: 0,
                      ),
                    ),

                    /// 🔥 Soft Gradient for Premium Feel
                    Container(
                      height: MediaQuery.of(context).size.height * 0.23,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),

                    /// 🔥 Service Name on Image
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        serviceModel?.name ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                /// 🔥 CONTENT SECTION
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Category
                      Row(
                        children: [
                          Icon(Icons.category_rounded,
                              size: 16,
                              color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              serviceModel?.category?.name ?? "N/A",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// Optional Divider
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
