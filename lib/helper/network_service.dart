import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _sub;

  final isOffline = false.obs;
  final showBanner = false.obs;
  final isBackOnline = false.obs;

  @override
  void onInit() {
    super.onInit();

    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);

      if (!hasConnection) {
        isOffline.value = true;
        showBanner.value = true;
        isBackOnline.value = false;
      } else {
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