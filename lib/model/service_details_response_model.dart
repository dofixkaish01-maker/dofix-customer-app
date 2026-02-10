import 'package:do_fix/model/service_model.dart';

class SingleServiceResponse {
  final String? responseCode;
  final String? message;
  final ServiceModel? content;
  final List<dynamic>? errors;

  SingleServiceResponse({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  factory SingleServiceResponse.fromJson(Map<String, dynamic> json) {
    return SingleServiceResponse(
      responseCode: json['response_code'],
      message: json['message'],
      content: json['content'] != null
          ? ServiceModel.fromJson(json['content'])
          : null,
      errors: json['errors'] ?? [],
    );
  }
}
