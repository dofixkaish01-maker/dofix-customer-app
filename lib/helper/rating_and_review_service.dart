import 'dart:convert';
import 'package:do_fix/utils/app_constants.dart';
import 'package:http/http.dart' as http;

class CustomerReviewService {
  final baseUrl = AppConstants.editCustomerReview;

  Future<Map<String, dynamic>> editReviewService(
      String customerID,
      String bearerToken,
      String zoneID,
      Map<String, dynamic> payload,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$customerID'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $bearerToken',
          'zoneID': zoneID,
        },
        body: payload,
      );

      // print('rating res body: ${response.body}');
      // print('rating req head: ${response.request?.headers}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Something went wrong",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}