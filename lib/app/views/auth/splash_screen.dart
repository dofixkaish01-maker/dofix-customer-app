import 'dart:async';
import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/tracking_controller.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AppsflyerSdk _appsFlyerSdk;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await TrackingController.requestTracking();

    // Facebook App Events
    final facebookAppEvents = FacebookAppEvents();
    facebookAppEvents.setAdvertiserTracking(enabled: true);
    facebookAppEvents.logEvent(name: "amrit_test_event");

    // AppsFlyer SDK init
    await initAppsFlyer();

    _route();
  }


  // Future<void> _initApp() async {
  //   await TrackingController.requestTracking();
  //   await Future.delayed(Duration(seconds: 3));
  //   _route();
  // }

  void _route() {
    Timer(const Duration(milliseconds: 1200), () {
      Get.find<AuthController>().isLoggedIn();
    });
  }

  Future<void> initAppsFlyer() async {
    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: "QPsc9zfWKAjutYjJgPVLWi",
      appId: "com.dofix.appcustomer", // iOS App ID
      showDebug: true,
    );

    _appsFlyerSdk = AppsflyerSdk(options);

    await _appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.size.height,
        width: Get.size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffffffff), Color(0xff207fa8)],
            stops: [0, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSize100),
          child: Center(
            child: Image.asset(
              width: 110,
              height: 110,
              Images.iclogo,
            ),
          ),
        ),
      ),
    );
  }
}
