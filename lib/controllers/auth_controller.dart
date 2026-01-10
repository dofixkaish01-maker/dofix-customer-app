import 'dart:convert';
import 'dart:developer';

import 'package:do_fix/helper/gi_dart.dart';
import 'package:do_fix/model/check_user_model.dart';
import 'package:do_fix/utils/app_constants.dart';
import 'package:do_fix/widgets/common_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/api.dart';
import '../data/repo/auth_repo.dart';
import '../helper/route_helper.dart';
import '../widgets/custom_snack_bar.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  final SharedPreferences sharedPreferences;
  final RxString phoneNumber = ''.obs;
  // String? _firebaseVerificationId;
  CheckUserModel? checkUserInfo;

  AuthController({
    required this.authRepo,
    required this.sharedPreferences,
  });

  DateTime? lastBackPressTime;

  String? token;
  Future<bool> handleOnWillPop() async {
    final now = DateTime.now();

    if (lastBackPressTime == null ||
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      updateLastBackPressTime(now);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      SystemNavigator.pop();
      return Future.value(false);
    }
    return Future.value(true);
  }

  void updateLastBackPressTime(DateTime time) {
    lastBackPressTime = time;
    update();
  }

  DateTime? _lastBackPressTime;

  Future<bool> willPopCallback() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      Get.showSnackbar(
        GetSnackBar(
          message: 'Press back again to exit',
          duration: Duration(seconds: 2),
        ),
      );
      return Future.value(false);
    }
    SystemNavigator.pop(); // Closes the app
    update();
    return Future.value(true);
  }

  // Future<void> sendOtpApiFirebase(String phone) async {
  //   showLoading();
  //   update();

  //   try {
  //     log("Phone Number : $phone");
  //     phoneNumber.value = phone;
  //     await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: "+91$phone",
  //       timeout: const Duration(seconds: 60),
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         // Auto-retrieval or instant verification
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //         hideLoading();
  //         showCustomSnackBar("Phone number automatically verified!",
  //             isError: false, isSuccess: true);
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         hideLoading();
  //         showCustomSnackBar("Verification failed: ${e.message}",
  //             isError: true);
  //       },
  //       codeSent: (String verificationId, int? resendToken) {
  //         _firebaseVerificationId = verificationId;
  //         hideLoading();
  //         showCustomSnackBar("OTP sent successfully!",
  //             isError: false, isSuccess: true);
  //         // Navigate to OTP verification screen, pass verificationId
  //         Get.toNamed(RouteHelper.getVerifyOtpRoute(phone));
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         // Auto-retrieval timed out
  //       },
  //     );
  //   } catch (e) {
  //     hideLoading();
  //     showCustomSnackBar("Something went wrong. Please try again. $e",
  //         isError: true);
  //   } finally {
  //     update();
  //   }
  // }

  // Future<void> verifyOtpFirebase(
  //     {required String otp, required String phone}) async {
  //   if (_firebaseVerificationId == null) {
  //     showCustomSnackBar("No verification ID found. Please request OTP again.",
  //         isError: true);
  //     return;
  //   }
  //   showLoading();
  //   update();

  //   try {
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: _firebaseVerificationId!,
  //       smsCode: otp,
  //     );
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     hideLoading();
  //     showCustomSnackBar("Phone number verified!",
  //         isError: false, isSuccess: true);

  //     await checkUserData(phone);
  //   } on FirebaseAuthException catch (e) {
  //     hideLoading();
  //     showCustomSnackBar("Invalid OTP: ${e.message}", isError: true);
  //   } catch (e) {
  //     hideLoading();
  //     showCustomSnackBar("Something went wrong. Please try again. $e",
  //         isError: true);
  //   } finally {
  //     update();
  //   }
  // }

  Future<void> sendOtpApi(String phone) async {
    if (phone.trim().length != 10) {
      showCustomSnackBar("Please enter valid phone number.", isError: true);
      return;
    }
    showLoading();
    update();
    try {
      debugPrint("Error sending OTP: 10 ${phone}");
      debugPrint("Error sending OTP: 10 ${phone.trim()}");
      Response response = await authRepo.sendOtpRepo(phone.trim());
      var responseData = jsonDecode(response.body);
      log("Error sending OTP: 100 ${response.body}");
      if (responseData == null) {
        throw Exception("Response data is null");
      }
      debugPrint("Response: ${responseData["message"]}");
      if (response.statusCode == 200) {
        if (responseData["message"]
                ?.toString()
                .contains("OTP sent successfully") ??
            false) {
          // Check if account is deleted (is_active = 0)
          if (responseData['userData'] != null &&
              responseData['userData']['is_active'] == 0) {
            hideLoading();
            showCustomSnackBar("Your account is deleted", isError: true);
            return;
          }

//TODO : hidden for release
          debugPrint("OTP: ${responseData['OTP']}");
          hideLoading();

          phoneNumber.value = phone;
          debugPrint("Phone Number: ${phoneNumber.value}");

          // Close any existing snackbars before navigation
          closeSnackBarIfActive();

          // Navigate to OTP screen immediately
          Get.toNamed(RouteHelper.getVerifyOtpRoute(phone));

          // Show success message after navigation
          showCustomSnackBar("OTP Sent Successfully!",
              isError: false, isSuccess: true);
        } else {
          closeSnackBarIfActive();

          debugPrint("Showing error snackbar...");
          showCustomSnackBar(responseData['message'], isError: false);
        }
      } else {
        debugPrint('Failed to send OTP: ${responseData['message']}');
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error sending OTP: 1 $e");
    } finally {
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      hideLoading();
      // update();
    }
  }

  Future<void> loginAsGuest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.token, AppConstants.guestToken);

    Get.offAllNamed(RouteHelper.getDashboardRoute());
  }

  Future<void> checkUserData(String phone) async {
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    showLoading();
    update();
    try {
      debugPrint("Phone: $phone");
      Response response = await authRepo.checkUser(phone.trim());
      var responseData = jsonDecode(response.body);
      log("Response: $responseData");

      if (response.statusCode == 200) {
        checkUserInfo = CheckUserModel.fromJson(responseData);

        hideLoading();
        showCustomSnackBar(checkUserInfo?.message ?? '',
            isError: false, isSuccess: true);
        if (checkUserInfo?.content?.profileCompleted == false) {
          token = checkUserInfo?.content?.token;
          update();
          Get.toNamed(RouteHelper.getAccountSetup(phone.trim()));
        } else {
          authRepo.saveUserToken(checkUserInfo?.content?.token ?? "");
          apiClient.updateHeader(checkUserInfo?.content?.token ?? "");
          init();
          Get.offAllNamed(RouteHelper.getDashboardRoute());
        }
      } else {
        closeSnackBarIfActive();
        hideLoading();
        showCustomSnackBar("Something went wrong", isError: true);
      }
    } catch (e) {
      print("Error sending OTP: 2 $e");
      closeSnackBarIfActive();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      hideLoading();
    } finally {
      update();
    }
  }

  Future<String?> getCurrentToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.token);
  }

  Future<bool> returnIsGuest() async {
    String? token = await getCurrentToken();
    if (token == AppConstants.guestToken) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> checkIfGuest() async {
    String? token = await getCurrentToken();
    if (token == AppConstants.guestToken) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Login Required",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    "Please login to access this feature.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: () {
                              Get.back();
                              logout();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Color(0xFF207FA7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
    }
  }

  Future<void> VerifyOtp(String phone, String otp) async {
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    if (otp.length != 4) {
      showCustomSnackBar("Please enter a valid 4-digit OTP", isError: true);
      return;
    }
    showLoading();
    update();
    try {
      Response response =
          await authRepo.verifyOtp(phone.trim(), otp.trim(), "");

      var responseData = jsonDecode(response.body);
      debugPrint("Response: $responseData");
      if (responseData['error'] != null &&
              responseData['error']
                  .toString()
                  .toLowerCase()
                  .contains('invalid') ||
          responseData['error'].toString().toLowerCase().contains('expired')) {
        hideLoading();
        update();
        log("INSIDE: Invalid or expired OTP");
        showCustomSnackBar("Invalid or expired OTP", isError: true);

        update();
        return;
      }
      if (response.statusCode == 200) {
        log("INSIDE: 200");
        debugPrint(" ${responseData.toString()}");
        if (responseData["message"]
            .toString()
            .contains("Successfully registered")) {
          log("INSIDE: Successfully registered");
          hideLoading();
          await Future.delayed(Duration(seconds: 1), () {});
          // showCustomSnackBar(responseData['message'],
          //     isError: false, isSuccess: true);
          if (responseData['content']['RegisterComplete'] == 0) {
            token = responseData['content']['token'];
            update();
            log("INSIDE: Setup account");
            Get.offAllNamed(RouteHelper.getAccountSetup(phone.trim()));
          } else {
            authRepo.saveUserToken(responseData['content']['token']);
            apiClient.updateHeader(responseData['content']['token']);
            init();
            log("INSIDE: dashboard");
            Get.offAllNamed(RouteHelper.getDashboardRoute());
          }
          // Get.toNamed(RouteHelper.getAccountSetup(phone.trim()));
          update();
        } else {
          update();
          closeSnackBarIfActive();
          hideLoading();
          if (responseData['error'] != null &&
                  responseData['error']
                      .toString()
                      .toLowerCase()
                      .contains('invalid') ||
              responseData['error']
                  .toString()
                  .toLowerCase()
                  .contains('expired')) {
            showCustomSnackBar("Invalid or expired OTP", isError: true);
          } else {
            showCustomSnackBar("Something went wrong please try again later",
                isError: true);
          }
        }
      } else {
        closeSnackBarIfActive();
        hideLoading();
        if (response.hasError) {
          showCustomSnackBar("Invalid OTP", isError: true);
        } else {
          showCustomSnackBar("Something went wrong", isError: true);
        }
        showCustomSnackBar("${response.hasError}", isError: true);
        update();
      }
    } catch (e) {
      print("Error sending OTP: 3 $e");
      closeSnackBarIfActive();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      hideLoading();
    } finally {
      update();
    }
  }

  Future<void> register(
      String email, String firstName, String lastName, String phone) async {
    showLoading();
    update();
    debugPrint("token $token");
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    try {
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        "zoneID": "e8554d44-dcf2-47c7-8cf9-400d05a1340f",
      };
      Response response = await authRepo.register(
          firstName.trim(), lastName.trim(), email, phone.trim(),
          headers: headers);

      var responseData = jsonDecode(response.body);
      debugPrint("Response Register: $responseData");
      if (response.statusCode == 200) {
        if (responseData["message"]
            .toString()
            .contains("Successfully registered")) {
          // showCustomSnackBar(responseData['message'],
          //     isError: false, isSuccess: true);

          if ((token ?? "").isNotEmpty) {
            authRepo.saveUserToken(token ?? "");
            apiClient.updateHeader(token, "");
            init();
            Get.offAllNamed(RouteHelper.dashboard);
          }
          // update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        print('Failed to send OTP ${responseData['message']}');
        hideLoading();
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
        update();
      }
    } catch (e) {
      print("Error  register: $e");
      hideLoading();
      // closeSnackBarIfActive();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
    } finally {
      update();
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    isLoggedIn();
  }

  Future<void> isLoggedIn() async {
    bool value = await authRepo.isLoggedIn();
    if (value) {
      Get.toNamed(RouteHelper.getDashboardRoute());
    } else {
      Get.toNamed(RouteHelper.getLoginRoute());
    }
  }

  void logout() {
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    authRepo.saveUserToken("");
    apiClient.updateHeader("");
    Get.offAllNamed(RouteHelper.getLoginRoute());
  }

  Future<void> deleteAccount({required String phoneNumber}) async {
    showLoading();
    update();
    try {
      Response response =
          await authRepo.deleteAccount(phone: phoneNumber.trim());
      var responseData = jsonDecode(response.body);
      log("Delete account Response: $responseData");
      if (response.statusCode == 200) {
        hideLoading();
        showCustomSnackBar(responseData['message'],
            isError: false, isSuccess: true);
        logout();
      } else {
        hideLoading();
        closeSnackBarIfActive();
        showCustomSnackBar("Something went wrong", isError: true);
      }
    } catch (e) {
      print("Error deleting account: $e");
      hideLoading();
      closeSnackBarIfActive();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
    } finally {
      update();
    }
  }
}
