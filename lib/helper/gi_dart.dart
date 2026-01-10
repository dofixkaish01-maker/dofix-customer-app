import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/booking_controller.dart';
import '../data/api/api.dart';
import '../data/repo/auth_repo.dart';
import '../data/repo/booking_repo.dart';
import '../utils/app_constants.dart';

Future<void> init() async {
  /// Repository
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences, fenix: true);
  Get.lazyPut(() => ApiClient(
      appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()));

  // /// Controller

  // Get.lazyPut(() => ProfileController());
  // Get.lazyPut(() => CouponController(couponRepo: Get.find()));
  // Get.lazyPut(() => AuthController(authRepo: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(
      () => DashBoardController(
          authRepo: Get.find(), sharedPreferences: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => BookingRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => AuthController(authRepo: Get.find(), sharedPreferences: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => BookingController(
          bookingRepo: Get.find(), sharedPreferences: Get.find()),
      fenix: true);
}
