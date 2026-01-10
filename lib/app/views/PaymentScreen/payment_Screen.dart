import 'dart:developer';
import 'package:do_fix/app/widgets/custom_appbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../utils/app_constants.dart';
import '../cart_screen/SubScreen/processing_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String url;
  final String? fromPage;
  final Function? onPressed;
  final Map<String, dynamic> data;
  const PaymentScreen(
      {super.key,
      required this.url,
      this.fromPage,
      required this.onPressed,
      required this.data});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  String? selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;

  @override
  void initState() {
    super.initState();
    selectedUrl = widget.url;
    _initData(widget.fromPage ?? "");
    // widget.onPressed;
    log("URL : ${widget.url}");
  }

  void _initData(String fromPage) async {
    browser = MyInAppBrowser(
        fromPage: fromPage, onPressed: widget.onPressed, data: widget.data);

    if (GetPlatform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);

      bool swAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController =
            ServiceWorkerController.instance();
        await serviceWorkerController
            .setServiceWorkerClient(ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (kDebugMode) {
              print(request);
            }
            return null;
          },
        ));
      }
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl!)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true, useOnLoadResource: true),
        browserSettings: InAppBrowserSettings(
            hideUrlBar: true, hideToolbarTop: GetPlatform.isAndroid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: 'Payment'.tr,
          isSearchButtonExist: false,
          isBackButtonExist: true,
          isCartButtonExist: false,
        ),
        body: Center(
          child: Stack(
            children: [
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary)),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class MyInAppBrowser extends InAppBrowser {
  final String fromPage;
  final Function? onPressed;
  final Map<String, dynamic> data;

  MyInAppBrowser(
      {required this.fromPage, required this.onPressed, required this.data});

  bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    _pageRedirect(url.toString(), onPressed, data);
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _pageRedirect(url.toString(), onPressed, data);
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if (_canRedirect) {
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Payment Failed"),
                ],
              ),
              content: const Text(
                "Your payment was not completed. Please try again or choose a different payment method.",
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Get.back(); // Optionally pop back to previous screen
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        },
      );
    }

    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {}

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

  void _pageRedirect(
      String url, Function? onpressed, Map<String, dynamic> data) async {
    if (kDebugMode) {
      print("inside_page_redirect");
    }
    log("url:$url");

    // onPressed;

    if (_canRedirect) {
      bool isSuccess = url.contains('success') &&
          url.contains(AppConstants.baseUrl) &&
          url.contains("flag");
      bool isFailed = url.contains('fail') &&
          url.contains(AppConstants.baseUrl) &&
          url.contains("flag");
      bool isCancel = url.contains('cancel') &&
          url.contains(AppConstants.baseUrl) &&
          url.contains("flag");

      if (kDebugMode) {
        print('This_called_1::::$url');
      }
      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
        close();
      }

      if (isSuccess) {
        Get.to(() => ProcessingScreen(
              data: data,
            ));
      } else {
        // debugPrint("Payment Failed");
        // showDialog(
        //   context: Get.context!,
        //   barrierDismissible: false,
        //   builder: (BuildContext context) {
        //     return WillPopScope(
        //       onWillPop: () async => false,
        //       child: AlertDialog(
        //         title: Row(
        //           children: const [
        //             Icon(Icons.error, color: Colors.red),
        //             SizedBox(width: 8),
        //             Text("Payment Failed"),
        //           ],
        //         ),
        //         content: const Text(
        //           "Your payment was not completed. Please try again or choose a different payment method.",
        //           style: TextStyle(fontSize: 14),
        //         ),
        //         actions: [
        //           TextButton(
        //             onPressed: () {
        //               Navigator.pop(context); // Close the dialog
        //               Get.back(); // Optionally pop back to previous screen
        //             },
        //             child: const Text("OK"),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // );
        // Get.offAll(()=>DashboardScreen(pageIndex: 0));
      }
    }
  }
}
