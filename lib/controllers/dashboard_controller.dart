import 'dart:developer';
import 'dart:io';

import 'package:do_fix/app/views/dashboard/dashboard_screen.dart';
import 'package:do_fix/app/views/services/service_details_screen.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/model/booking_model.dart';
import 'package:do_fix/model/category_model.dart';
import 'package:do_fix/model/user_model.dart';
import 'package:do_fix/model/variation_model.dart';
import 'package:do_fix/utils/app_constants.dart';
import 'package:do_fix/widgets/common_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../app/views/ProfileScreen/profile_screen.dart';
import '../app/views/SuccessFullScreen/success_full_screen.dart';
import '../app/views/account/account_screen.dart';
import '../app/views/bookingScreen/booking_history_screen.dart';
import '../app/views/cart_screen/cart_screen.dart';
import '../app/views/home/SubScreens/category_to_services.dart';
import '../app/views/home/component/banner_widget.dart';
import '../app/views/home/home_screen.dart';
import '../app/views/no_service_screen.dart';
import '../app/views/services/services.dart';
import '../data/api/api.dart';
import '../data/repo/auth_repo.dart';
import '../helper/gi_dart.dart';
import '../model/address_model.dart';
import '../model/booking_response.dart';
import '../model/pages_model.dart';
import '../model/pop_model.dart';
import '../model/service_model.dart' as sv;
import '../widgets/custom_snack_bar.dart';

enum DiscountType { general, coupon, campaign, refer }

class DashBoardController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  final SharedPreferences sharedPreferences;

  DashBoardController({
    required this.authRepo,
    required this.sharedPreferences,
  });

  bool _isLoginLoading = false;

  bool get isLoginLoading => _isLoginLoading;
  CategoryModel? categoryList = CategoryModel(data: []);
  sv.Services? topRated = sv.Services(data: []);
  sv.Services? quickRepair = sv.Services(data: []);
  sv.Services? servicesListing = sv.Services(data: []);
  sv.Services? categoriesToServiceListing = sv.Services(data: []);
  sv.SubCategoryModel? subCategoryModelListing = sv.SubCategoryModel(data: []);
  sv.ServiceModel serviceModel = sv.ServiceModel();
  RxList<sv.ServiceModel> serviceModelSearchList = <sv.ServiceModel>[].obs;
  BookingModel bookingModel = BookingModel(data: []);
  sv.CartResponseModel cartModel = sv.CartResponseModel();

  String? address = "";
  RxString shortAddress = ''.obs;
  List<BannerItem> banners1 = [];
  List<BannerItem> banner2 = [];
  List<sv.SubCategory> selectedSubCategories = [];
  TextEditingController addressController = TextEditingController();
  AddressResponse addressResponse = AddressResponse(data: []);
  List<AddressData> selectedAddressLists = [];
  String lat = "";
  String long = "";
  String zoneIdForBooking = "";
  RxBool isGuest = true.obs;
  RxBool createBookingLoader = false.obs;

  ApiResponse apiResponse = ApiResponse(
      responseCode: '',
      message: '',
      content: ContentData(images: PolicyImages()),
      errors: []);

  @override
  void onInit() {
    super.onInit();

    getCartListing(limit: "100", offset: "1", isRoute: false, showLoader: true);
  }

  void updateLatLong(String lat, String long) {
    if (kDebugMode) {
      this.lat = "28.5503";
      this.long = "77.2502";
    } else {
      this.lat = lat;
      this.long = long;
    }
    getZoneIdForBooking();
    update();
  }

  void updateAddress(String address) {
    this.addressController.text = address;
    update();
  }

  Future<void> getFeaturedCategories(String limit, String offset,
      [bool? isShowLoading]) async {
    log("Inside 22222");
    if (isShowLoading ?? false) {
      showLoading();
    }
    categoryList?.data?.clear();
    update();
    try {
      Response response = await authRepo.featuredCategories(limit, offset);
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      debugPrint("Category Listing===>:featuredcategory:: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          categoryList = CategoryModel.fromJson(responseData['content']);
          update();
          await getTopRated("20", "1");
          await getQuickRepair("20", "1");
        } else {
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:1 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      hideLoading();
      // update();
    }
  }

  static double calculateDiscount(
      {required List<sv.CartItem> cartList,
      required DiscountType discountType,
      int daysCount = 1}) {
    double discount = 0;
    for (var cartModel in cartList) {
      if (discountType == DiscountType.general) {
        discount = discount + (cartModel.discountAmount * daysCount);
      } else if (discountType == DiscountType.campaign) {
        discount = discount + (cartModel.campaignDiscount * daysCount);
      } else if (discountType == DiscountType.coupon) {
        discount = discount + (cartModel.couponDiscount * daysCount);
      }
    }
    return discount;
  }

  double vat = 0.0;
  static double calculateVat(
      {required List<sv.CartItem> cartList, int daysCount = 1}) {
    double vat = 0;
    for (var cartModel in cartList) {
      vat = vat + (cartModel.taxAmount * daysCount);
    }
    return vat;
  }

  double subTotal = 0.0;
  static double calculateSubTotal(
      {required List<sv.CartItem> cartList, int daysCount = 1}) {
    double subTotalPrice = 0;
    for (var cartModel in cartList) {
      subTotalPrice = subTotalPrice +
          ((cartModel.serviceCost * cartModel.quantity) * daysCount);
    }
    return subTotalPrice;
  }

  Future<void> getTopRated(String limit, String offset,
      [bool? isShowLoading]) async {
    if (isShowLoading ?? false) {
      showLoading();
    }
    topRated?.data?.clear();
    update();
    try {
      Response response = await authRepo.getToprated(limit, offset);
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      log("Top rated Listing===>: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          topRated = sv.Services.fromJson(responseData['content']);
          update();
        } else {
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:2 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      hideLoading();
      // update();
    }
  }

  Future<void> getQuickRepair(String limit, String offset,
      [bool? isShowLoading]) async {
    if (isShowLoading ?? false) {
      showLoading();
    }
    quickRepair?.data?.clear();
    update();
    try {
      Response response = await authRepo.getQuickRepair(limit, offset);
      // var responseData = jsonDecode(response.body);
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      debugPrint("Category Listing===>: quick::${response.body}");
      debugPrint("Category Listing===>: quick::$responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          quickRepair = sv.Services.fromJson(responseData['content']);
          update();
        } else {
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      // showCustomSnackBar("Something went wrong. Please try again. $e",
      //     isError: true);
      debugPrint("Error fetching categories:3 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      hideLoading();
      // update();
    }
  }

  Future<void> getData(String limit, String offset,
      [bool? isShowLoading]) async {
    if (isShowLoading ?? false) {
      showLoading();
    }

    categoryList?.data?.clear();
    update();

    try {
      Response response = await authRepo.categories(limit, offset);
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      debugPrint("Category Listing===>:getdata:: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          categoryList = CategoryModel.fromJson(responseData['content']);
          hideLoading();
          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:4 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      hideLoading();
      // update();
    }
  }

  double discount = 0.0;

  Future<void> getCartListing(
      {required String limit,
      required String offset,
      required bool showLoader,
      required bool? isRoute}) async {
    try {
      Response response = await authRepo.cart(limit, offset);
      var responseData = response.body;
      log("get cart Response data: $responseData");
      if (responseData == null) {
        throw Exception("Response data is null");
      }

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          cartModel = sv.CartResponseModel.fromJson(responseData);
          discount = calculateDiscount(
              cartList: cartModel.content?.cart?.data ?? [],
              discountType: DiscountType.general);
          vat = calculateVat(
            cartList: cartModel.content?.cart?.data ?? [],
          );
          subTotal = calculateSubTotal(
            cartList: cartModel.content?.cart?.data ?? [],
          );
          debugPrint("Discount: $discount");
          if (isRoute ?? true) {
            Get.to(() => CartScreen());
          }
          update();
        } else {
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching cartItem: $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      if (showLoader) hideLoading();
      // update();
    }
  }

  Future<void> getServices(String limit, String offset) async {
    showLoading();
    update();
    try {
      Response response = await authRepo.service(limit, offset);
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      debugPrint("Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          servicesListing = sv.Services.fromJson(responseData['content']);
          hideLoading();
          update();
        } else {
          hideLoading();

          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();

        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      hideLoading();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:5 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      hideLoading();
      // update();
    }
  }

  List<Variation> variations = [];

  Future<void> getServicesDetails(
    String id,
  ) async {
    // showLoading();
    update();
    try {
      Response response = await authRepo.serviceDetails(id);
      var responseData = response.body;
      log("eeee Response data: $responseData");
      if (responseData == null) {
        throw Exception("Response data is null");
      }
      log("Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          serviceModel = sv.ServiceModel.fromJson(responseData['content']);
          debugPrint("Service Model: ${serviceModel.variations?.length}");
          hideLoading();
          Get.to(() => ServiceDetails());
          update();
        } else {
          hideLoading();

          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();

        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      hideLoading();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:6 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> getAddressLists() async {
    showLoading();
    update();
    try {
      Response response = await authRepo.addressLists();
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      log("Response data Address: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          addressResponse = AddressResponse.fromJson(responseData['content']);
          debugPrint("Service Model: ${serviceModel.variations?.length}");
          hideLoading();
          update();
        } else {
          hideLoading();

          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();

        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      hideLoading();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching address: $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      hideLoading();
      // update();
    }
  }

  Future<bool> addAddress(AddressData data) async {
    showLoading();
    update();
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': apiClient.mainHeaders['Authorization'] ?? ""
    };
    var request = http.Request(
        'POST', Uri.parse('https://panel.dofix.in/api/v1/customer/address'));
    request.body = json.encode({
      "id": null,
      "address_type": "service",
      "address_label": data.addressType,
      "contact_person_name": data.contactPersonName,
      "contact_person_number": "+91${data.contactPersonNumber}",
      "address": data.address,
      "lat": data.lat,
      "lon": data.lon,
      "city": data.city,
      "zip_code": data.zipCode,
      "country": data.country,
      "zone_id": data.zoneId,
      "_method": null,
      "street": data.street,
      "house": data.house,
      "floor": data.floor,
      "available_service_count": null
    });

    debugPrint("Request Body: ${json.encode(request.body)}");
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      // debugPrint(responseBody);
      await Get.find<DashBoardController>().getAddressLists();
      hideLoading();
      Get.back();
      return true;
    } else {
      debugPrint(responseBody.toString());
      return false;
    }
  }

  RxString lastStatus = "".obs;

  Future<void> getBooking(Map<String, dynamic> query) async {
    bookingModel.data?.clear();
    showLoading();
    update();
    try {
      log("Query: $query");
      Response response = await authRepo.bookings(query);
      var responseData = response.body;

      log("Response data: $responseData");

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      log("rrrr Response data booking: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          bookingModel = BookingModel.fromJson(responseData['content']);
          hideLoading();
          update();
        } else {
          hideLoading();

          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();

        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      hideLoading();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching bookings: $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      hideLoading();
      // update();
    }
  }

  BookingResponse? bookingResponse;

  Future<void> getBookingDetails(String id) async {
    showLoading();
    update();
    try {
      Response response = await authRepo.bookingDetails(id);
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }

      log("Response data booking details: $responseData");
      await Future.delayed(Duration(seconds: 1));
      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          bookingResponse = BookingResponse.fromJson(responseData);
          hideLoading();
          update();

          // ✅ Show Dialog with Booking Details
          final booking = bookingResponse?.content;

          if (booking != null) {
            debugPrint("Showing DialogBx : ${responseData}");
          } else {
            debugPrint("Booking details not available");
            showCustomSnackBar("Booking details not available", isError: true);
          }
        } else {
          hideLoading();
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      hideLoading();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching bookings: $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      hideLoading();
    }
  }

  List<PopupMenuModel> getPopupMenuList(
      {required String status, bool isRepeatBooking = false}) {
    if (status == "pending") {
      return [
        PopupMenuModel(
            title: "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(
            title: "download_invoice", icon: Icons.file_download_outlined),
        PopupMenuModel(title: "cancel", icon: Icons.cancel_outlined),
      ];
    } else if (status == "accepted" || status == "ongoing") {
      return [
        PopupMenuModel(
            title: "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(
            title: "download_invoice", icon: Icons.file_download_outlined),
      ];
    } else if (status == "canceled" || status == "completed") {
      return [
        PopupMenuModel(
            title: "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(
            title: "download_invoice", icon: Icons.file_download_outlined),
        if (!isRepeatBooking)
          PopupMenuModel(title: "rebook", icon: Icons.repeat),
      ];
    }
    return [];
  }

  Future<void> postOrder(dynamic body, List<String> selectedVariations,
      {required bool showLoader}) async {
    log("Starting postOrder request...");
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);

    if (showLoader) {
      showLoading();
      update();
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': apiClient.mainHeaders["Authorization"] ?? "",
    };

    var request = http.Request(
      'POST',
      Uri.parse(AppConstants.baseUrl + AppConstants.bookingRequest),
    );
    request.body = json.encode({
      "booking_type": "daily",
      "dates": null,
      "message": "${body["message"]}",
      "guest_id": "",
      "partialPayment": "",
      "is_partial": 0,
      "new_user_info": null,
      "payment_method": body['payment_method'],
      "service_address": json.encode(
        {
          "id": null,
          "address_type": "service",
          "address_label": "${body["address_label"]}",
          "contact_person_name": "${body["name"]}",
          "contact_person_number": "+91${body["mobile_number"]}",
          "address": "${body["address"]}",
          "lat": "${body["lat"]}",
          "lon": "${body["lng"]}",
          "city": "${body["city"]}",
          "zip_code": "${body["zip_code"]}",
          "country": "${body["country"]}",
          "zone_id": "${body["zone_id"]}",
          "_method": null,
          "street": "${body["street"]}",
          "house": "",
          "floor": "",
          "available_service_count": null
        },
      ),
      "service_address_id": null,
      "service_schedule": "${body["date"]} ${body["time"]}",
      "service_type": "regular",
      "zone_id": apiClient.mainHeaders["zoneID"] ?? "",
      "service_preference": "${body["service_preference"]}",
    });

    request.headers.addAll(headers);
    log("Booking Request Body: ${request.body}");
    log("Sending booking request to server...");
    try {
      // Add timeout to prevent hanging requests
      http.StreamedResponse response = await request.send().timeout(
        Duration(seconds: 120),
        onTimeout: () {
          throw Exception('Request timed out after 120 seconds');
        },
      );
      log("Received response from server with status: ${response.statusCode}");
      String responseBody = await response.stream.bytesToString();
      log("Booking Response: $responseBody");

      if (response.statusCode == 200) {
        // Parse response to check the flag
        try {
          Map<String, dynamic> responseJson = json.decode(responseBody);
          String flag = responseJson['flag'] ?? '';
          String message = responseJson['message'] ?? '';

          if (flag != 'failed') {
            // Success case
            hideLoading();
            update();
            Get.offAll(() => SuccessFullScreen());
            print("✅ Success Response: $responseBody");
          } else {
            // API returned failed flag
            hideLoading();
            update();
            print("❌ API returned failed flag: $message");
            showCustomSnackBar(
                message.isNotEmpty
                    ? message
                    : "Booking request failed. Please try again.",
                isError: true);
          }
        } catch (parseError) {
          // If response parsing fails, treat as error
          hideLoading();
          update();
          print("❌ Failed to parse response: $parseError");
          print("📌 Response Body: $responseBody");
          showCustomSnackBar("Invalid response from server. Please try again.",
              isError: true);
        }
      } else {
        hideLoading();
        update();
        print("❌ API Error ${response.statusCode}");
        print("📌 Response Reason: ${response.reasonPhrase}");
        print("📌 Response Body: $responseBody");
        print("📌 Headers: ${response.headers}");

        // Show error message to user
        showCustomSnackBar(
            response.reasonPhrase ??
                "Booking request failed. Please try again.",
            isError: true);
      }
    } catch (e, stackTrace) {
      log("❌ Booking request failed with exception: $e");
      hideLoading();
      update();
      debugPrint("❌ Exception: $e");
      debugPrint("📌 Stack Trace: $stackTrace");

      // Show specific error message to user
      String errorMessage =
          "Network error occurred. Please check your connection and try again.";
      if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        errorMessage =
            "Booking request timed out. This might be due to server overload. Please try again in a few moments.";
        log("⏰ Request timed out after 30 seconds");
      } else if (e.toString().contains('connection') ||
          e.toString().contains('SocketException')) {
        errorMessage =
            "Connection failed. Please check your internet connection and try again.";
        log("🔌 Connection error detected");
      } else if (e.toString().contains('FormatException')) {
        errorMessage = "Server response format error. Please try again later.";
        log("📄 Response format error");
      }

      log("🚨 Showing error message to user: $errorMessage");
      showCustomSnackBar(errorMessage, isError: true);
    }
  }

  Future<void> addToCart(
    dynamic body,
    List<String> selectedVariations,
  ) async {
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);

    showLoading();
    update();

    var headers = {
      'Content-Type': 'application/json',
      // 'Accept': 'application/json',
      'Authorization': apiClient.mainHeaders["Authorization"] ?? "",
      'zoneID': apiClient.mainHeaders["zoneID"] ?? "",
    };

    var request = http.Request(
      'POST',
      Uri.parse('https://panel.dofix.in/api/v1/customer/cart/add'),
    );

    String variationsJson = jsonEncode(selectedVariations[0]);

    Map<String, dynamic> requestBody = {
      "service_id": body["service_id"],
      "category_id": body["category_id"],
      "sub_category_id": body["sub_category_id"],
      "quantity": "1",
      "variant_key": jsonDecode(variationsJson),
    };
    log("Add to card body : ${requestBody}");
    request.bodyBytes = utf8.encode(jsonEncode(requestBody));
    request.headers.addAll(headers);

    debugPrint("Request Body: ${jsonEncode(requestBody)}");

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("✅ Success Response: $responseBody");
        await Future.delayed(Duration(seconds: 1));
        await getCartListing(
            limit: "100", offset: "1", isRoute: false, showLoader: true);
        hideLoading();
        await Future.delayed(Duration(seconds: 1));
        // Notify UI that cart has been updated
        update(['cart_total', 'service_container']);
        // Update the specific service item too
        update(['cart_${body["service_id"]}_${jsonDecode(variationsJson)}']);
        selectedVariations.clear();
      } else {
        log("Add to card body : catch : ${response.statusCode} and $responseBody");
        print("❌ API Error ${response.statusCode}");
        print("📌 Response Reason: ${response.reasonPhrase}");
        print("📌 Response Body: $responseBody");
        print("📌 Headers: ${response.headers}");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Exception: $e");
      debugPrint("📌 Stack Trace: $stackTrace");
      log("Add to card body : catch : $e and $stackTrace");
    } finally {
      hideLoading();
      update();
    }
  }

  Future<void> getZone() async {
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    try {
      Response response =
          await authRepo.zones(latitude.toString(), longitude.toString());
      var responseData = response.body;

      if (responseData == null) {
        hideLoading();
        throw Exception("Response data is null");
      }
      log("dddd get zone Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          log("dddd Zone: $responseData");
          String? token =
              await sharedPreferences.getString(AppConstants.token).toString();
          apiClient.updateHeader(
              token, responseData['content']['zone']['id'].toString());
          debugPrint(
              "Zone ID: ${responseData['content']['zone']['id'].toString()}");
          // debugPrint("Zone ID: ${apiClient.mainHeaders}");
          await Future.delayed(Duration(milliseconds: 10));
          // getLocationData();
          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          // showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        hideLoading();
        // showCustomSnackBar(responseData['message'], isError: true);

        screens = [
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
        ];
        await init();

        Get.offAll(() => DashboardScreen(pageIndex: 0));
        update();
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:7 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      await getLocationData();
      update();
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> getZoneIdForBooking() async {
    // ApiClient apiClient = ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    try {
      Response response = await authRepo.zones(lat.toString(), long.toString());
      var responseData = response.body;

      if (responseData == null) {
        hideLoading();
        throw Exception("Response data is null");
      }
      debugPrint("Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          debugPrint("Zone: $responseData");
          debugPrint(
              "Zone ID: ${responseData['content']['zone']['id'].toString()}");
          zoneIdForBooking = responseData['content']['zone']['id'].toString();
          debugPrint("Zone ID: $zoneIdForBooking");
          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          // showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        hideLoading();
        // showCustomSnackBar(responseData['message'], isError: true);
        update();
      }
    } catch (e) {
      // showCustomSnackBar("Something went wrong. Please try again. $e",
      //     isError: true);
      debugPrint("Error fetching categories:8 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> getPagesData() async {
    showLoading();
    // ApiClient apiClient = ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    try {
      Response response = await authRepo.pages();
      var responseData = response.body;

      if (responseData == null) {
        hideLoading();
        throw Exception("Response data is null");
      }
      debugPrint("Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          apiResponse = ApiResponse.fromJson(responseData);
          hideLoading();
          // debugPrint("Zone ID: $zoneIdForBooking");
          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        hideLoading();
        showCustomSnackBar(responseData['message'], isError: true);
        update();
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:9 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> getCategoriesToServices(
      {required String id,
      required String limit,
      required String offset,
      bool? isLoading}) async {
    categoriesToServiceListing = sv.Services(data: []);
    if (isLoading ?? false) {
      showLoading();
    }
    update();

    try {
      Response response =
          await authRepo.categoriesToServices(id, limit, offset);
      var responseData = response.body;

      if (responseData == null) {
        hideLoading();
        throw Exception("cccc Response data is null");
      }
      log("cccc Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          categoriesToServiceListing =
              sv.Services.fromJson(responseData['content']);
          if ((categoriesToServiceListing?.data ?? []).isNotEmpty) {
            hideLoading();
            Get.to(() => CategoryToServices());
          }

          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          Get.to(() => CategoryToServices());
          // showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        closeSnackBarIfActive();
        hideLoading();
        showCustomSnackBar(responseData['message'], isError: true);

        screens = [
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
        ];
        Get.offAll(() => DashboardScreen(pageIndex: 0));
        update();
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:10 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> getCategoriesToSubCategories(
      {required String id,
      required String limit,
      required String offset}) async {
    subCategoryModelListing = sv.SubCategoryModel(data: []);
    showLoading();
    update();

    try {
      Response response =
          await authRepo.categoriesToSubCategories(id, limit, offset);
      var responseData = response.body;

      if (responseData == null) {
        hideLoading();
        throw Exception("Response data is null");
      }
      debugPrint("Response data SubCategories: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          subCategoryModelListing =
              sv.SubCategoryModel.fromJson(responseData['content']);
          update();
          if ((subCategoryModelListing?.data ?? []).isNotEmpty) {
            selectedSubCategories.clear();
            selectedSubCategories.add((subCategoryModelListing?.data ?? [])[0]);
            update();
            hideLoading();
            getCategoriesToServices(
                id: (subCategoryModelListing?.data ?? [])[0].id.toString(),
                limit: "10",
                offset: "1",
                isLoading: false);
          }
          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          showCustomSnackBar(
            responseData['message'],
            isError: true,
            isSuccess: false,
          );
        }
      } else {
        closeSnackBarIfActive();
        hideLoading();
        showCustomSnackBar(
          responseData['message'],
          isError: false,
          isSuccess: true,
        );

        screens = [
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
          NoServiceScreen(
            message: responseData['message'].toString(),
          ),
        ];
        init();
        Get.offAll(() => DashboardScreen(pageIndex: 0));
        update();
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:11 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> getLocationData() async {
    _isLoginLoading = true;
    showLoading();
    update();

    try {
      Response response =
          await authRepo.addressData(latitude.toString(), longitude.toString());
      var responseData = response.body;
      log("dddd Response data: $responseData");
      if (responseData == null) {
        throw Exception("Response data is null");
      }
      log("dddd Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          await getBanners();
          address = responseData["content"]["results"][0]["formatted_address"]
              .toString();
          shortAddress.value = responseData["content"]["results"][0]
              ["address_components"][1]["long_name"];
          log("dddd Fetched address: $address");
          log("dddd Fetched short address: ${shortAddress.value}");
          if ((address ?? "").isNotEmpty) {
            // await getFeaturedCategories("6", "1");
            await getCartListing(
                limit: "100", offset: "1", isRoute: false, showLoader: false);
          }
          // hideLoading();
          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:12 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> getBanners() async {
    try {
      Response response = await authRepo.banners();
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      log("Banner Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          debugPrint("Banners: $responseData");
          responseData['content']['data'].forEach((element) {
            String imagePath = element['banner_image_full_path'];
            String bannerRedirect = element['resource_id'];
            String bannerType = element['resource_type'];

            if (element['position'].toString() == "1") {
              if (!banners1.any((item) => item.imageUrl == imagePath)) {
                banners1.add(
                  BannerItem(
                    imageUrl: imagePath,
                    redirectId: bannerRedirect,
                    bannertype: bannerType,
                    onTap: () {
                      try {
                        print("category id: ${bannerRedirect}, ${bannerType}");
                        if (bannerType == "category") {
                          Get.find<DashBoardController>()
                              .getCategoriesToSubCategories(
                                  id: bannerRedirect, limit: '10', offset: "1");
                        } else if (bannerType == "service") {
                          Get.find<DashBoardController>().getServicesDetails(
                            bannerRedirect,
                          );
                        } else {
                          openExternalLink(bannerRedirect);
                        }
                      } catch (e) {
                        debugPrint("onClick Error: $e");
                      }
                    },
                  ),
                );
                update();
              }
            } else {
              if (!banner2.any((item) => item.imageUrl == imagePath)) {
                banner2.add(
                  BannerItem(
                    imageUrl: imagePath,
                    redirectId: bannerRedirect,
                    bannertype: bannerType,
                    onTap: () {
                      try {
                        print("category id: ${bannerRedirect}, ${bannerType}");
                        if (bannerType == "category") {
                          Get.find<DashBoardController>()
                              .getCategoriesToSubCategories(
                                  id: bannerRedirect, limit: '10', offset: "1");
                        } else if (bannerType == "service") {
                          Get.find<DashBoardController>().getServicesDetails(
                            bannerRedirect,
                          );
                        } else {
                          openExternalLink(bannerRedirect);
                        }
                      } catch (e) {
                        debugPrint("onClick Error: $e");
                      }
                    },
                  ),
                );
                update();
              }
            }
          });

          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:13 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  void openExternalLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
      print('Could not launch $url');
    }
  }

  Future<void> getSearchList(Map<String, dynamic> body) async {
    _isLoginLoading = true;
    serviceModelSearchList.value = [];
    update();
    try {
      Response response = await authRepo.searchList(body);
      await Future.delayed(Duration(seconds: 15));
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      log("Response data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          responseData['content']['services']['data'].forEach((element) {
            serviceModelSearchList.add(sv.ServiceModel.fromJson(element));
          });
          _isLoginLoading = false;
          update();
        } else {
          _isLoginLoading = false;

          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
          update();
        }
      } else {
        _isLoginLoading = false;

        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:14 $e");

      closeSnackBarIfActive();
      _isLoginLoading = false;
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> updateQuantity(String quantity, String id) async {
    showLoading();
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    var headers = apiClient.mainHeaders;
    log("Headers: $headers");
    debugPrint(
        "uri: ${Uri.parse('https://panel.dofix.in/api/v1/customer/cart/update-quantity/$id?$quantity')}");
    var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'https://panel.dofix.in/api/v1/customer/cart/update-quantity/$id?quantity=$quantity'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      hideLoading();
      print(responseBody);
      await getCartListing(
          limit: "100", offset: "1", isRoute: false, showLoader: true);
      // Notify UI that cart total has been updated
      update(['cart_total', 'service_container']);
    } else {
      print(response.reasonPhrase);
      print(responseBody);
    }
  }

  Future<void> removeItem(String id) async {
    showLoading();
    ApiClient apiClient = ApiClient(
        appBaseUrl: AppConstants.baseUrl, sharedPreferences: sharedPreferences);
    var headers = apiClient.mainHeaders;
    debugPrint(
        "uri: ${Uri.parse('https://panel.dofix.in/api/v1/customer/cart/remove/$id')}");

    var request = http.Request('DELETE',
        Uri.parse('https://panel.dofix.in/api/v1/customer/cart/remove/$id'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      hideLoading();
      print(responseBody);
      await getCartListing(
          limit: "100", offset: "1", isRoute: false, showLoader: false);
      // Notify UI that cart total has been updated
      update(['cart_total', 'service_container']);
    } else {
      print(response.reasonPhrase);
      print(responseBody);
    }
  }

  List<Widget> screens = [
    HomeScreen(),
    const ServiceScreens(),
    const BookingHostoryScreen(),
    const AccountScreen(),
  ];

  double? latitude = 28.5463443;
  double? longitude = 77.2519989;

  List<String> selectedVariations = [];
  final bookingController = Get.find<BookingController>();
  Future<void> handleLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    log("22222 Permission: $permission");
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      showLoading();
      await fetchUserLocation();
      await Get.find<DashBoardController>().getFeaturedCategories("6", "1");
      await bookingController.getBookingSetup();
      await Get.find<DashBoardController>().getBanners();
      hideLoading();
    } else {
      await showLocationPermissionDialog(context);
      showLoading();
      await Get.find<DashBoardController>().getFeaturedCategories("6", "1");
      await bookingController.getBookingSetup();
      await Get.find<DashBoardController>().getBanners();
      hideLoading();
    }
  }

  Future<void> showLocationPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Required"),
          content: Text(
            "DoFix needs your location to determine your service zone and provide the best available service providers in your area. We also use location when you book services to save exact coordinates for accurate address tracking on maps.",
          ),
          actions: [
            //TODO : Commented to deploy on AppStore
            //             TextButton(
            //   onPressed: () {
            //     print(
            //         "DashboardScreen state: ${DashboardScreen.globalKey.currentState}");
            //     DashboardScreen.globalKey.currentState?.setPage(0);
            //     Navigator.pop(context);
            //     hideLoading();
            //   },
            //   child: Text("Cancel"),
            // ),

            TextButton(
              onPressed: () async {
                // showLoading();
                // await Get.find<DashBoardController>()
                //     .getFeaturedCategories("6", "1");
                Navigator.pop(context);
                await requestLocationPermission();
                // await bookingController.getBookingSetup();
                // await Get.find<DashBoardController>().getBanners();
                // DashboardScreen.globalKey.currentState?.setPage(0);
                // hideLoading();
                // Get.back();
              },
              child: Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        // Still continue to home screen, but use default location
        DashboardScreen.globalKey.currentState?.setPage(0);
        hideLoading();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log("Location permission permanently denied. Enable from settings.");

      DashboardScreen.globalKey.currentState?.setPage(0);
      hideLoading();
      showCustomSnackBar(
          "Location permission denied. You can manually select your location in settings.",
          isError: false);
      return;
    }
    await fetchUserLocation();
  }

  Future<void> fetchUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    log("dddd Latitude: ${position.latitude}, Longitude: ${position.longitude}");

    if (kDebugMode) {
      latitude = 28.5503;
      longitude = 77.2502;
    } else {
      longitude = position.longitude;
      latitude = position.latitude;
    }
    update();
    Future.delayed(Duration(milliseconds: 10));
    await getZone();
  }

  UserModel userModel = UserModel(
      id: "",
      firstName: "",
      lastName: "",
      email: "",
      phone: "",
      identificationNumber: "",
      identificationType: "",
      identificationImage: [],
      dateOfBirth: "",
      gender: "",
      profileImage: "",
      fcmToken: "",
      isPhoneVerified: false,
      isEmailVerified: false,
      phoneVerifiedAt: "",
      emailVerifiedAt: "",
      isActive: false,
      userType: "",
      rememberToken: "",
      deletedAt: "",
      createdAt: "",
      updatedAt: "",
      walletBalance: 0,
      loyaltyPoint: 0,
      refCode: "",
      referredBy: "",
      loginHitCount: 0,
      isTempBlocked: false,
      tempBlockTime: "",
      currentLanguageKey: "",
      profileImageFullPath: "",
      identificationImageFullPath: [],
      storage: "");

  Future<void> getUserInfo([bool? isRedirect]) async {
    showLoading();
    update();
    try {
      Response response = await authRepo.userInfo();
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }
      log("Profile data: $responseData");

      if (response.statusCode == 200) {
        if (responseData['message']
            .toString()
            .contains("Successfully data fetched")) {
          userModel = UserModel.fromJson(responseData['content']);
          hideLoading();
          update();
          if (isRedirect ?? false) {
            Get.to(() => ProfileScreen());
          }
        } else {
          hideLoading();

          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();

        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      hideLoading();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching categories:15 $e");
      closeSnackBarIfActive();
    } finally {
      _isLoginLoading = false;
      // showCustomSnackBar("Something went wrong. Please try again.", isError: true);
      // hideLoading();
      // update();
    }
  }

  Future<void> updateProfile(String firstName, String lastName, String email, File? profileImage) async {
    ApiClient apiClient = ApiClient(
      appBaseUrl: AppConstants.baseUrl,
      sharedPreferences: sharedPreferences,
    );

    var headers = {
      "Authorization": apiClient.mainHeaders["Authorization"] ?? "",
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppConstants.baseUrl + AppConstants.updateProfile),
    );

    request.fields.addAll({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    });

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_img', profileImage.path),
      );
    }
    log("My Headers: $headers");
    log("My Request: ${request.fields}");

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Get.snackbar("Success", "Profile updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else {
      print(await response.stream.bytesToString());
      print('Error: ${response.statusCode}');
      print(response.reasonPhrase);
    }
  }

  void addVariation(String? variantKey) {
    if (variantKey != null && !selectedVariations.contains(variantKey)) {
      selectedVariations.add(variantKey);
    }
    log("Variant key Key is $variantKey");
    update();
  }

  void setSelectedVariation(String variantKey) {
    selectedVariations
      ..clear()
      ..add(variantKey);
    update();
  }

  void removeVariation(String? variantKey) {
    if (variantKey != null) {
      selectedVariations.remove(variantKey);
    }
    update();
  }
}
