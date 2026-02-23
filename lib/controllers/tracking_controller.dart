import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:get/get.dart';

class TrackingController extends GetxController {

 static Future<void> requestTracking() async {
    final status =
    await AppTrackingTransparency.requestTrackingAuthorization();
    print("Tracking Status: $status");
  }

}