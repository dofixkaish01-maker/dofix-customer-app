import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;
  static Future<String?> getToken() async {
    await _messaging.requestPermission();
    return await _messaging.getToken();
  }
  static void onTokenRefresh(Function(String token) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}