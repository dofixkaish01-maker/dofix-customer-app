// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
// import '../app/views/ProfileScreen/profile_screen.dart';
// import '../data/api/api.dart';
// import '../data/repo/auth_repo.dart';
// import '../model/user_model.dart';
// import '../utils/app_constants.dart';
//
// class UserController extends GetxController {
//   UserModel userModel = UserModel.empty();
//
//   Future<void> getUserInfo([bool? isRedirect]) async {
//     try {
//       final response = await AuthRepo(apiClient: null, sharedPreferences: null).userInfo();
//       var data = response.body;
//       if (response.statusCode == 200 && data['message'].contains("Successfully data fetched")) {
//         userModel = UserModel.fromJson(data['content']);
//         update();
//         if (isRedirect ?? false) Get.to(() => ProfileScreen());
//       }
//     } catch (e) {
//       print("Error fetching user info: $e");
//     }
//   }
//
//   Future<void> updateProfile(String firstName, String lastName, String email, File? profileImage) async {
//     ApiClient apiClient = ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: null);
//     var request = http.MultipartRequest('POST', Uri.parse(AppConstants.baseUrl + AppConstants.updateProfile));
//
//     request.fields.addAll({
//       'first_name': firstName,
//       'last_name': lastName,
//       'email': email,
//     });
//
//     if (profileImage != null) {
//       request.files.add(await http.MultipartFile.fromPath('profile_img', profileImage.path));
//     }
//
//     request.headers.addAll({
//       "Authorization": apiClient.mainHeaders["Authorization"] ?? "",
//     });
//
//     http.StreamedResponse response = await request.send();
//     if (response.statusCode == 200) {
//       Get.snackbar("Success", "Profile updated successfully");
//     } else {
//       print("Failed to update profile: ${response.statusCode}");
//     }
//   }
// }
