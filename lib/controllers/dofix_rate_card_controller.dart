import 'dart:convert';

import 'package:do_fix/widgets/app_snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import '../model/rate_card_model.dart';

class DofixRateCardController extends GetxController {
  var isLoading = false.obs;
  var rateCardList = <RateCardModel>[].obs;

  String? categoryId;

  void setCategoryId(String id) {
    categoryId = id;
    getRateCard();
  }

  Future<void> getRateCard() async {
    if (categoryId == null) return;

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(
          "https://panel.dofix.in/api/v1/customer/category/category-extra",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_TOKEN",
          "zoneID": "YOUR_ZONE_ID",
        },
        body: jsonEncode({
          "category_id": categoryId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final rateCard = DofixRateCart.fromJson(jsonData);
        rateCardList.value = rateCard.content;
      } else {
        AppSnackBar.show(
            title: "Error",
            message: "Server error"
        );
      }
    } catch (e) {
      AppSnackBar.show(
          title: "Error",
          message: "Something went wrong"
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
