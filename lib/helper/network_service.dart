import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _sub;

  final isSlow = false.obs;
  final isOffline = false.obs;
  final showBanner = false.obs;
  final isBackOnline = false.obs;

  Future<bool> isNetworkSlow() async {
    try {
      final stopwatch = Stopwatch()..start();

      final result = await InternetAddress.lookup('google.com');

      stopwatch.stop();

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print("Ping time: ${stopwatch.elapsedMilliseconds} ms");

        //  threshold decide karo
        if (stopwatch.elapsedMilliseconds > 800) {
          return true; // slow network
        } else {
          return false; // good network
        }
      }
    } catch (_) {
      return true; // treat as slow/offline
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();

    _sub = _connectivity.onConnectivityChanged.listen((results) async {
      final hasConnection = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);

      if (!hasConnection) {
        isOffline.value = true;
        showBanner.value = true;
        isBackOnline.value = false;
        isSlow.value = false;
      } else {
        final slow = await isNetworkSlow();

        isSlow.value = slow;

        if (isOffline.value) {
          isOffline.value = false;
          isBackOnline.value = true;
          showBanner.value = true;

          Future.delayed(const Duration(seconds: 2), () {
            showBanner.value = false;
          });
        }
      }
    });
  }

  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}