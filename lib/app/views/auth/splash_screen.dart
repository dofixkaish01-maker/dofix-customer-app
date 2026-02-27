import 'dart:async';

import 'package:do_fix/helper/route_helper.dart';
import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/images.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/tracking_controller.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _initApp() async {
    await TrackingController.requestTracking();

    final facebookAppEvents = FacebookAppEvents();

    await facebookAppEvents.setAdvertiserTracking(enabled: true);
    await facebookAppEvents.logEvent(name: "amrit_test_event");

    await Future.delayed(const Duration(seconds: 3));
    Get.offNamed(RouteHelper.getLoginRoute());
  }
  void initState() {
    super.initState();
    _initApp();
  }

  // Future<void> _initApp() async {
  //   await TrackingController.requestTracking();
  //   await Future.delayed(Duration(seconds: 3));
  //   _route();
  // }

  void _route() {
    Timer(const Duration(seconds: 2), () {
      Get.find<AuthController>().isLoggedIn();
    });
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
