import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_fix/model/service_model.dart';

Future<ServiceModel> fetchService(String serviceId) async {
  final response = await http.get(
    Uri.parse('https://panel.dofix.in/api/v1/service/$serviceId'),
    headers: {
      'Authorization': 'Bearer <your_token_here>', // agar token chahiye
    },
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return ServiceModel.fromJson(jsonData['data']);
  } else {
    throw Exception('Failed to load service');
  }
}
