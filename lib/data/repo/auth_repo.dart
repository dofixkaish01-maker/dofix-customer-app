import 'package:do_fix/model/address_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import '../api/api.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<bool> saveUserToken(
    String token,
  ) async {
    apiClient.token = token;
    apiClient.updateHeader(token);
    return await sharedPreferences.setString(AppConstants.token, token);
  }

  Future<bool> isLoggedIn() async {
    final String? isTokenAvailable =
        await sharedPreferences.getString(AppConstants.token);
    return isTokenAvailable != null && isTokenAvailable.isNotEmpty;
  }

  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  Future<bool> clearSharedData() async {
    await sharedPreferences.remove(AppConstants.token);
    return true;
  }

  Future<Response> sendOtpRepo(
    String? phoneNo,
  ) async {
    return await apiClient.postData(AppConstants.sendOtp,
        {"phone": "+91$phoneNo", "user_type": "customer"});
  }

  Future<Response> verifyOtp(
      String? phoneNo, String? otp, String? fcmToken) async {
    return await apiClient.postData(AppConstants.verifyOtp, {
      "phone": "+91$phoneNo",
      "otp": otp ?? "",
      "fcmToken": fcmToken ?? "",
      "user_type": "customer"
    });
  }

  Future<Response> checkUser(
    String? phoneNo,
  ) async {
    return await apiClient.postData(
      AppConstants.checkUser,
      {
        "phone": "+91$phoneNo",
      },
    );
  }

  Future<Response> register(
      String? firstName, String? lastName, String? email, String? phone,
      {Map<String, String>? headers}) async {
    return await apiClient.postData(
        AppConstants.register,
        {
          "first_name": firstName ?? "",
          "last_name": lastName ?? "",
          "email": email ?? "",
          "phone": "+91$phone",
          "user_type": "customer"
        },
        headers: headers);
  }

  Future<Response> categories(
    String? limit,
    String? offset,
  ) async {
    return await apiClient.getData(AppConstants.category,
        query: {
          "limit": limit,
          "offset": offset,
        },
        method: "GET");
  }

  Future<Response> featuredCategories(
    String? limit,
    String? offset,
  ) async {
    return await apiClient.getData(AppConstants.featuredCategory,
        query: {
          "limit": limit,
          "offset": offset,
        },
        method: "GET");
  }

  Future<Response> getToprated(
    String? limit,
    String? offset,
  ) async {
    return await apiClient.getData(AppConstants.topRated, method: "GET");
  }

  Future<Response> getQuickRepair(
    String? limit,
    String? offset,
  ) async {
    return await apiClient.getData(AppConstants.quickRepair, method: "GET");
  }

  Future<Response> cart(
    String? limit,
    String? offset,
  ) async {
    return await apiClient.getData(AppConstants.cartListing,
        query: {
          "limit": limit,
          "offset": offset,
        },
        method: "GET");
  }

  Future<Response> service(
    String? limit,
    String? offset,
  ) async {
    return await apiClient.getData(AppConstants.service,
        query: {
          "limit": limit,
          "offset": offset,
        },
        method: "GET");
  }

  Future<Response> serviceDetails(String id) async {
    return await apiClient.getData(AppConstants.serviceDetails,
        query: {"id": id}, method: "GET");
  }

  Future<Response> addressLists() async {
    return await apiClient.getData(AppConstants.addressLists,
        query: {
          "limit": "100",
          "offset": "1",
        },
        method: "GET");
  }

  Future<Response> bookings(Map<String, dynamic> query) async {
    return await apiClient.getData(AppConstants.bookings,
        query: query, method: "GET");
  }

  Future<Response> bookingDetails(String id) async {
    return await apiClient.getData(AppConstants.bookingDetails + "$id",
        method: "GET");
  }

  Future<Response> addAddress(AddressData data) async {
    return await apiClient.getData(AppConstants.addAddress,
        body: data.toJson(), method: "POST");
  }

  Future<Response> booking(dynamic body) async {
    return await apiClient.postData(AppConstants.booking, body);
  }

  Future<Response> zones(
    String? latitude,
    String? longitude,
  ) async {
    return await apiClient.getData(AppConstants.zones,
        query: {
          "lat": latitude,
          "lng": longitude,
        },
        method: "GET");
  }

  Future<Response> pages() async {
    return await apiClient.getData(AppConstants.pages, method: "GET");
  }

  Future<Response> categoriesToServices(
      String? id, String? limit, String? offset) async {
    return await apiClient.getData(AppConstants.categoriesToServices,
        query: {
          "limit": limit,
          "offset": offset,
          "sub_category_id": id,
        },
        method: "GET");
  }

  Future<Response> categoriesToSubCategories(
      String? id, String? limit, String? offset) async {
    return await apiClient.getData(AppConstants.categoriesToSubCategories,
        query: {
          "limit": limit,
          "offset": offset,
          "id": id,
        },
        method: "GET");
  }

  Future<Response> addressData(
    String? latitude,
    String? longitude,
  ) async {
    return await apiClient.getData(AppConstants.geoCodeLocation,
        query: {
          "lat": latitude,
          "lng": longitude,
        },
        method: "GET");
  }

  Future<Response> banners() async {
    return await apiClient.getData(
      AppConstants.banners,
      query: {
        "limit": "100",
        "offset": "1",
      },
      method: "GET",
    );
  }

  Future<Response> searchList(Map<String, dynamic> body) async {
    debugPrint("Body: $body");
    return await apiClient.getData(
      AppConstants.search,
      query: {
        "limit": "10",
        "offset": "1",
      },
      body: body,
      method: "POST",
    );
  }

  Future<Response> userInfo() async {
    return await apiClient.getData(AppConstants.user, method: "GET");
  }

  Future<Response> updateUserInfo(String firstName, String lastName,
      String email, FilePickerResult profileImage) async {
    return await apiClient.postMultipartData(AppConstants.updateProfile, {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
    }, [], [
      MultipartDocument("profile_image", profileImage)
    ]);
  }

  Future<Response> deleteAccount({required String phone}) async {
    return await apiClient.postData(AppConstants.changeStatus, {
      "is_active": '0',
      "phone": phone,
    });
  }

// Future<Response> getUserData() async {
//   return await apiClient.getData(AppConstants.myProfileUrl,method: 'POST');
// }
//
// Future<Response> getPrivacyPolicy(String data) async {
//   return await apiClient.getData(AppConstants.privacyUrl+"${data}",method: 'GET');
// }
}
