import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_fix/model/service_model.dart';

Future<ServiceModel> fetchService(String serviceId) async {
  final response = await http.get(
    Uri.parse('https://panel.dofix.in/api/v1/service/$serviceId'),
    headers: {
      'Authorization': 'Bearer <your_token_here>',
    },
  );

  // status code check
  if (response.statusCode != 200) {
    throw Exception('Server error: ${response.statusCode}');
  }

  // response JSON hai ya nahi
  if (!response.headers['content-type']!.contains('application/json')) {
    throw Exception('Invalid response format');
  }

  final jsonData = json.decode(response.body);

  // data null safety
  if (jsonData['data'] == null) {
    throw Exception('Service data missing');
  }

  return ServiceModel.fromJson(jsonData['data']);
}
