import 'package:do_fix/app/views/auth/account_setup_screen.dart';
import 'package:do_fix/app/views/auth/login.dart';
import 'package:do_fix/app/views/auth/login_location_pick_screen.dart';
import 'package:do_fix/app/views/auth/login_verification.dart';
import 'package:do_fix/app/views/auth/splash_screen.dart';
import 'package:do_fix/app/views/dashboard/dashboard_screen.dart';
import 'package:get/get.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String verifyOtp = '/verify-otp';
  static const String accountSetup = '/account-setup';
  static const String loginLocationPick = '/login-location-pick';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String redeemedOffer = '/redeemed-offer';
  static const String category = '/category';
  static const String allCategoryRoute = '/allCategoryRoute';
  static const String categoryCoupons = '/category-coupons';
  static const String profile = '/profile';

  /// Routes ==================>
  static String getInitialRoute() => initial;

  static String getSplashRoute() => splash;

  static String getLoginRoute() => login;

  static String getVerifyOtpRoute(String? phoneNo) =>
      '$verifyOtp?phoneNo=$phoneNo';

  static String getHomeRoute() => home;

  static String getAccountSetup(String? phoneNo) =>
      '$accountSetup?phoneNo=$phoneNo';

  static String getLoginLocationRoute() => loginLocationPick;

  static String getDashboardRoute() => dashboard;

  static String getRedeemedOffer() => redeemedOffer;

  static String getCategoryRoute() => category;

  static String getCategoryCouponsRoute(String? categoryId) =>
      '$categoryCoupons?categoryId=$categoryId';

  static String getProfileScreen() => profile;

  /// Pages ==================>
  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(
        name: verifyOtp,
        page: () => LoginVerificationScreen(
              phoneNo: Get.parameters['phoneNo'],
            )),
    GetPage(
        name: accountSetup,
        page: () => AccountSetupScreen(
              phone: Get.parameters['phoneNo'] ?? "",
            )),
    GetPage(name: loginLocationPick, page: () => LoginLocationPickScreen()),
    GetPage(
        name: dashboard,
        page: () => DashboardScreen(
              pageIndex: 0,
            )),
    // GetPage(name: redeemedOffer, page: () =>  RedeemedOffer()),
    // GetPage(name: category, page: () =>  CategoryScreen()),
    // GetPage(name: profile, page: () =>  ProfileScreen()),
  ];
}
