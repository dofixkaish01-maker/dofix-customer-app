import 'package:get/get.dart';

class CartController extends GetxController {
  /// MAIN SERVICE
  String? serviceId;
  String? variantKey;

  int quantity = 1;

  /// EXTRA SERVICES (Swiggy style)
  List<String> selectedExtraServices = [];

  /// SET MAIN SERVICE
  void setService({
    required String serviceId,
    required String variantKey,
  }) {
    this.serviceId = serviceId;
    this.variantKey = variantKey;
    quantity = 1;
    selectedExtraServices.clear();
    update();
  }

  /// QUANTITY
  void increaseQty() {
    quantity++;
    update();
  }

  void decreaseQty() {
    if (quantity > 1) {
      quantity--;
      update();
    }
  }

  /// EXTRA SERVICE
  void toggleExtraService(String id) {
    if (selectedExtraServices.contains(id)) {
      selectedExtraServices.remove(id);
    } else {
      selectedExtraServices.add(id);
    }
    update();
  }

  /// RESET AFTER ADD
  void clearCartTemp() {
    serviceId = null;
    variantKey = null;
    quantity = 1;
    selectedExtraServices.clear();
  }
}
