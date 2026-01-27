// import 'dart:developer';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:do_fix/controllers/dashboard_controller.dart';
// import 'package:do_fix/app/views/dashboard/dashboard_screen.dart';
//
// class LocationController extends GetxController {
//   double? latitude = 28.5463443;
//   double? longitude = 77.2519989;
//
//   Future<void> handleLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse) {
//       await fetchUserLocation();
//     } else {
//       // Show permission dialog
//       await requestLocationPermission();
//     }
//   }
//
//   Future<void> requestLocationPermission() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       DashboardScreen.globalKey.currentState?.setPage(0);
//       return;
//     }
//     await fetchUserLocation();
//   }
//
//   Future<void> fetchUserLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     if (Get.isDebugMode) {
//       latitude = 28.5503;
//       longitude = 77.2502;
//     } else {
//       latitude = position.latitude;
//       longitude = position.longitude;
//     }
//
//     // Call DashboardController to get Zone
//     await Get.find<DashBoardController>().getZone();
//     update();
//   }
// }
