import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:do_fix/app/views/PaymentScreen/payment_Screen.dart';
import 'package:do_fix/app/views/services/service_details_screen.dart';
import 'package:do_fix/app/widgets/custom_selection_widget.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/utils/common_functions.dart';
import 'package:do_fix/widgets/common_loading.dart';
import 'package:do_fix/widgets/custom_dot_loader.dart';
import 'package:do_fix/widgets/custom_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controllers/dashboard_controller.dart';
import '../../../../data/api/api.dart';
import '../../../../model/address_model.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/date_converter.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../widgets/custom_button_widget.dart';
import '../SuccessFullScreen/success_full_screen.dart';

// DashBoardController, DateConverter, formatTimeOfDay24Hour
//use for open razor pay payment getway
// enum PaymentMethod { cash, razor_pay }
enum PaymentMethod { cash_after_service, razor_pay }

class BookingScreen extends StatefulWidget {
  final double cartTotalPrice;

  const BookingScreen({super.key, required this.cartTotalPrice});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final bookingController = Get.find<BookingController>();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController mapController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalController = TextEditingController();

  TextEditingController assignNameController = TextEditingController();
  TextEditingController assignPhoneController = TextEditingController();
  TextEditingController assignEmailController = TextEditingController();

  bool isServiceAvailable = true;
  String regionMessage = "";
  LatLng? _lastValidLatLng;

  final Set<String> _allowedCities = {
    'ghaziabad',
    'greater noida',
    'noida',
    'delhi',
    'new delhi',
    'faridabad',
    'gurugram',
    'gurgaon',
  };

  final LatLngBounds _allowedBounds = LatLngBounds(
    southwest: LatLng(28.20, 76.80),
    northeast: LatLng(28.95, 77.85),
  );

  final FocusNode addressFocus = FocusNode();
  final FocusNode mapFocus = FocusNode();
  AddressData? selectedAddress;
  String country = "";
  String state = "";
  String city = "";
  String street = "";
  String postalCode = "";

  // late Razorpay _razorpay;

  GoogleMapController? _mapController;
  final dashboardController = Get.find<DashBoardController>();
  LatLng _selectedLatLng = const LatLng(28.7041, 77.1025);
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  String addressType = "home";
  String servicePreference = "onsite";
  PaymentMethod _paymentMethod = PaymentMethod.cash_after_service;

  @override
  void initState() {
    super.initState();

    addressController.text = "";
    streetController.text = "";
    Get.find<DashBoardController>().addressController.text = "";
    _lastValidLatLng = _selectedLatLng;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<DashBoardController>().getUserInfo(false);
      _setInitialLocation();
    });
  }

  bool _isAllowedCity(String cityName) {
    return _allowedCities.contains(cityName.trim().toLowerCase());
  }

  Future<void> _applyPlacemarkToFields(
    Placemark place,
    StateSetter modalSetState,
  ) async {
    modalSetState(() {
      floorController.text = "";
      houseController.text = "";
      streetController.text = place.street ?? place.name ?? "";
      mapController.text =
          "${place.street ?? place.name ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
              .replaceAll(RegExp(r'(, )+'), ', ')
              .replaceAll(RegExp(r'^, |, $'), '');

      city = place.locality ?? place.subAdministrativeArea ?? "";
      state = place.administrativeArea ?? "";
      country = place.country ?? "";
      street = place.street ?? place.name ?? "";
      postalCode = place.postalCode ?? "";

      stateController.text = place.administrativeArea ?? "";
      countryController.text = place.country ?? "";
      postalController.text = place.postalCode ?? "";
    });

    _lastValidLatLng = _selectedLatLng;

    Get.find<DashBoardController>().updateLatLong(
      _selectedLatLng.latitude.toString(),
      _selectedLatLng.longitude.toString(),
    );
  }

  Future<void> _validateSelectedLocation(StateSetter modalSetState) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        _selectedLatLng.latitude,
        _selectedLatLng.longitude,
      );

      if (placemarks.isEmpty) {
        modalSetState(() {
          isServiceAvailable = false;
          regionMessage = "Service not available in this region";
        });
        return;
      }

      final place = placemarks.first;

      final cityName = (place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              "")
          .trim()
          .toLowerCase();

      final allowed = _isAllowedCity(cityName);

      if (allowed) {
        modalSetState(() {
          isServiceAvailable = true;
          regionMessage = "";
        });

        await _applyPlacemarkToFields(place, modalSetState);
      } else {
        modalSetState(() {
          isServiceAvailable = false;
          regionMessage = "Service not available in this region";
        });
      }
    } catch (e) {
      debugPrint("Location validation error: $e");
      modalSetState(() {
        isServiceAvailable = false;
        regionMessage = "Unable to verify this location";
      });
    }
  }

  Future<void> _handleSearchSelection(
    double lat,
    double lng,
    StateSetter modalSetState,
  ) async {
    modalSetState(() {
      _selectedLatLng = LatLng(lat, lng);
    });

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedLatLng, 15),
    );

    await _validateSelectedLocation(modalSetState);
  }

  // void initState() {
  //   super.initState();
  //
  //   addressController.text = "";
  //   streetController.text = "";
  //   Get.find<DashBoardController>().addressController.text = "";
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     await Get.find<DashBoardController>().getUserInfo(false);
  //     _setInitialLocation();
  //   });
  //   // _razorpay = Razorpay();
  //   // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  //   // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  //   // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  //   _lastValidLatLng = _selectedLatLng;
  // }

  bool isCashPayment() {
    return _paymentMethod == PaymentMethod.cash_after_service;
  }

  String getPaymentMethodForApi() {
    if (_paymentMethod == PaymentMethod.cash_after_service) {
      return "cash_after_service";
    } else if (_paymentMethod == PaymentMethod.razor_pay) {
      return "razor_pay";
    }
    return "cash_after_service"; // default fallback
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   // Payment successful
  //   print("Payment Success: ${response.paymentId}");
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   // Payment failed
  //   print("Payment Error: ${response.code} | ${response.message}");
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   // External wallet selected
  //   print("External Wallet: ${response.walletName}");
  // }

  // void openCheckout() {
  //   log("Inside openCheckout");
  //   var options = {
  //     'key': 'rzp_test_DZ43simWiGyPpB',
  //     'amount': 50000, // Amount in paise (e.g., 50000 = ₹500)
  //     'name': 'DoFix',
  //     'description': 'Service Payment',
  //     'prefill': {'contact': '9876543210', 'email': 'user@example.com'},
  //     'external': {
  //       'wallets': ['paytm']
  //     }
  //   };

  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     log("Inside openCheckout ${e.toString()}");
  //   }
  // }

  // @override
  // void dispose() {
  //   _razorpay.clear();
  //   super.dispose();
  // }

  List<TimeOfDay> _generateTimeSlots(DateTime date) {
    List<TimeOfDay> slots = [];
    int startHour = 9;
    int endHour = 20;
    for (int hour = startHour; hour <= endHour; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
    }
    return slots;
  }

  bool _isSlotEnabled(DateTime date, TimeOfDay slot) {
    DateTime now = DateTime.now();
    DateTime slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      slot.hour,
      slot.minute,
    );
    DateTime minAllowed = now.add(Duration(hours: 1, minutes: 0));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return slotDateTime.isAfter(minAllowed);
    }
    return true;
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> _setInitialLocation() async {
    debugPrint("Use Current Location inside");
    showLoading();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      hideLoading();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        hideLoading();
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _selectedLatLng = LatLng(position.latitude, position.longitude);
      _lastValidLatLng = _selectedLatLng;
    });

    await _getAddressFromLatLng(_selectedLatLng);
  }

  // Future<void> _setInitialLocation() async {
  //   debugPrint("Use Current Location inside");
  //   showLoading();
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     hideLoading();
  //     // showCustomSnackBar("Location services are disabled.");
  //     return;
  //   }
  //
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.deniedForever) {
  //       hideLoading();
  //       // showCustomSnackBar("Location services are disabled.");
  //       return;
  //     } else if (permission == LocationPermission.denied) {
  //       hideLoading();
  //       // showCustomSnackBar("Location services are disabled.");
  //       return;
  //     }
  //   }
  //
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _selectedLatLng = LatLng(position.latitude, position.longitude);
  //   });
  //   await _getAddressFromLatLng(LatLng(position.latitude, position.longitude));
  // }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isEmpty) {
        hideLoading();
        return;
      }

      Placemark place = placemarks.first;

      final cityName = (place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              "")
          .trim()
          .toLowerCase();

      final allowed = _isAllowedCity(cityName);

      setState(() {
        isServiceAvailable = allowed;
        regionMessage = allowed ? "" : "Service not available in this region";

        addressController.text = "";
        Get.find<DashBoardController>().addressController.text = "";

        city = place.locality ?? place.subAdministrativeArea ?? "";
        state = place.administrativeArea ?? "";
        country = place.country ?? "";
        street = place.street ?? place.name ?? "";
        postalCode = place.postalCode ?? "";

        mapController.text =
            "${place.street ?? place.name ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
                .replaceAll(RegExp(r'(, )+'), ', ')
                .replaceAll(RegExp(r'^, |, $'), '');
      });

      if (allowed) {
        _lastValidLatLng = position;
        Get.find<DashBoardController>().updateLatLong(
          position.latitude.toString(),
          position.longitude.toString(),
        );
      }

      Get.find<DashBoardController>().update();
      hideLoading();
    } catch (e) {
      debugPrint("getAddressFromLatLng error: $e");
      hideLoading();
    }
  }

  // Future<void> _getAddressFromLatLng(LatLng position) async {
  //   try {
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(position.latitude, position.longitude);
  //     Placemark place = placemarks[0];
  //     setState(() {
  //       // addressController.text =
  //       //     "${place.street}, ${place.locality}, ${place.country}";
  //       // Get.find<DashBoardController>().addressController.text =
  //       //     "${place.street}, ${place.locality}, ${place.country}";
  //       addressController.text = "";
  //       Get.find<DashBoardController>().addressController.text = "";
  //       city = place.locality ?? "";
  //       state = place.administrativeArea ?? "";
  //       country = place.country ?? "";
  //       street = place.street ?? "";
  //       postalCode = place.postalCode ?? "";
  //       mapController.text =
  //           "${place.street},${place.locality}, ${place.country}";
  //       Get.find<DashBoardController>().updateLatLong(
  //         position.latitude.toString(),
  //         position.longitude.toString(),
  //       );
  //     });
  //     Get.find<DashBoardController>().update();
  //     hideLoading();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Widget buildAnimatedItem({required int index, required Widget child}) {
    final bool fromLeft = index.isEven;

    return child;
  }

  void showAddressChoiceDialog(
    BuildContext context,
    List<AddressData> addressList,
    Function(AddressData) onSelectAddress,
  ) {
    if (addressList.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "No Saved Addresses",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "You don't have any saved addresses yet.",
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add New Address"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showAddNewAddressDialog(context);
                  },
                ),
              )
            ],
          );
        },
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    /// Drag Handle
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    /// Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Choose Address",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          /// Cancel Icon
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Divider(),

                    /// Address List
                    Expanded(
                      child: ListView.builder(
                        // padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: addressList.length,
                        itemBuilder: (context, index) {
                          final address = addressList[index];
                          final isSelected = selectedAddress == address;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAddress = address;
                              });
                              onSelectAddress(address);

                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.08)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color:
                                        isSelected ? Colors.blue : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          CommonFunctions()
                                              .capitalizeFirstLetter(
                                                  address.addressLabel),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          address.address,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: Colors.blue)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    /// Add New Address Button
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            "Add New Address",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(
                              color: Colors.blue, // Border Color Added
                              width: 1.5,
                            ),
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            showAddNewAddressDialog(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // void showAddressChoiceDialog(
  //   BuildContext context,
  //   List<AddressData> addressList,
  //   Function(AddressData) onSelectAddress,
  // ) {
  //   if (addressList.isEmpty) {
  //     // Show AlertDialog when list is empty
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //           title: const Text("No Saved Addresses"),
  //           content: const Text("You don't have any saved addresses yet."),
  //           actions: [
  //             OutlinedButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 showAddNewAddressDialog(context);
  //                 setState(() {
  //                   selectedAddress = null;
  //                 });
  //               },
  //               child: const Text("Add New Address"),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   } else {
  //     // Show ModalBottomSheet with StatefulBuilder
  //     showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //       ),
  //       builder: (context) {
  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             return DraggableScrollableSheet(
  //               expand: false,
  //               initialChildSize: 0.6,
  //               minChildSize: 0.4,
  //               maxChildSize: 0.9,
  //               builder: (_, controller) {
  //                 return SafeArea(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(16),
  //                     child: Column(
  //                       children: [
  //                         const Text(
  //                           "Choose Address",
  //                           style: TextStyle(
  //                               fontSize: 18, fontWeight: FontWeight.bold),
  //                         ),
  //                         const SizedBox(height: 10),
  //                         // ListTile(
  //                         //   onTap: () async {
  //                         //     debugPrint("Use Current Location");
  //                         //     await _setInitialLocation();
  //                         //     setState(() {
  //                         //       debugPrint("Use Current Location setstate");
  //                         //       selectedAddress = null;
  //                         //       // Navigator.of(context).pop();
  //                         //       Get.back();
  //                         //     });
  //                         //   },
  //                         //   leading: Icon(
  //                         //     selectedAddress != null
  //                         //         ? Icons.location_searching
  //                         //         : Icons.my_location,
  //                         //     color: Colors.blue,
  //                         //   ),
  //                         //   title: const Text("Use Current Location"),
  //                         // ),
  //                         const Divider(),
  //                         Expanded(
  //                           child: ListView.builder(
  //                             controller: controller,
  //                             itemCount: addressList.length,
  //                             itemBuilder: (context, index) {
  //                               final address = addressList[index];
  //                               return RadioListTile<AddressData>(
  //                                 value: address,
  //                                 selected: selectedAddress == address,
  //                                 groupValue: selectedAddress,
  //                                 onChanged: (value) {
  //                                   setState(() {
  //                                     selectedAddress = value;
  //                                   });
  //                                   onSelectAddress(value!);
  //                                 },
  //                                 title: Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     Expanded(
  //                                       child: Text(
  //                                         "(${CommonFunctions().capitalizeFirstLetter(address.addressLabel)}) ${address.address}",
  //                                         maxLines: 2,
  //                                         overflow: TextOverflow.ellipsis,
  //                                       ),
  //                                     ),
  //                                     // IconButton(
  //                                     //   icon: const Icon(Icons.edit,
  //                                     //       color: Colors.grey),
  //                                     //   onPressed: () {
  //                                     //     Navigator.of(context).pop();
  //                                     //     showAddNewAddressDialog(context);
  //                                     //   },
  //                                     // ),
  //                                   ],
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                         ),
  //                         TextButton(
  //                           onPressed: () {
  //                             Navigator.of(context).pop();
  //                             showAddNewAddressDialog(context);
  //                           },
  //                           child: const Text("Add New Address"),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         );
  //       },
  //     );
  //   }
  // }

  void showAddNewAddressDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: buildGoogleMapWithDetailsDialog(sheetContext),
      ),
    );
  }

  Widget buildGoogleMapWithDetailsDialog(BuildContext context1) {
    return StatefulBuilder(
      builder: (context, modalSetState) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context1).unfocus();
                        Navigator.of(context1).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Add Address",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                buildAnimatedItem(
                  index: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onVerticalDragUpdate: (_) {},
                              child: SizedBox(
                                height: 200,
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _selectedLatLng,
                                        zoom: 15,
                                      ),
                                      cameraTargetBounds:
                                          CameraTargetBounds(_allowedBounds),
                                      minMaxZoomPreference:
                                          const MinMaxZoomPreference(10, 18),
                                      onMapCreated: (controller) {
                                        _mapController = controller;
                                      },
                                      onCameraMove: (position) {
                                        modalSetState(() {
                                          _selectedLatLng = position.target;
                                        });
                                      },
                                      onCameraIdle: () async {
                                        await _validateSelectedLocation(
                                          modalSetState,
                                        );
                                      },
                                      gestureRecognizers: {
                                        Factory<OneSequenceGestureRecognizer>(
                                          () => EagerGestureRecognizer(),
                                        ),
                                      },
                                    ),
                                    const Center(
                                      child: Icon(
                                        Icons.location_pin,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            GooglePlaceAutoCompleteTextField(
                              focusNode: mapFocus,
                              textEditingController: mapController,
                              googleAPIKey:
                                  "AIzaSyBLI5I6o95GqluNuRh0YT3zRj5yqoix8zA",
                              inputDecoration: InputDecoration(
                                hintText: "Search location",
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              debounceTime: 600,
                              itemClick: (prediction) async {
                                final lat =
                                    double.tryParse(prediction.lat ?? "");
                                final lng =
                                    double.tryParse(prediction.lng ?? "");

                                if (lat == null || lng == null) return;

                                FocusScope.of(context).unfocus();

                                modalSetState(() {
                                  mapController.text =
                                      prediction.description ?? "";
                                });

                                await _handleSearchSelection(
                                  lat,
                                  lng,
                                  modalSetState,
                                );
                              },
                              getPlaceDetailWithLatLng: (prediction) async {
                                final lat =
                                    double.tryParse(prediction.lat ?? "");
                                final lng =
                                    double.tryParse(prediction.lng ?? "");

                                if (lat == null || lng == null) return;

                                await _handleSearchSelection(
                                  lat,
                                  lng,
                                  modalSetState,
                                );
                              },
                            ),
                            if (!isServiceAvailable) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3F0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFC9BD),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_off_outlined,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        regionMessage,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                buildAnimatedItem(
                  index: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Address Type",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Radio<String>(
                            value: "home",
                            groupValue: addressType,
                            onChanged: (value) =>
                                modalSetState(() => addressType = value!),
                          ),
                          const Text("Home"),
                          Radio<String>(
                            value: "office",
                            groupValue: addressType,
                            onChanged: (value) =>
                                modalSetState(() => addressType = value!),
                          ),
                          const Text("Office"),
                          Radio<String>(
                            value: "other",
                            groupValue: addressType,
                            onChanged: (value) =>
                                modalSetState(() => addressType = value!),
                          ),
                          const Text("Other"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                const Text(
                  'House No.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),

                buildAnimatedItem(
                  index: 11,
                  child: CustomTextField(
                    controller: houseController,
                    hintText: "Enter house number",
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Floor',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),

                buildAnimatedItem(
                  index: 12,
                  child: CustomTextField(
                    controller: floorController,
                    hintText: "Enter floor",
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Street / Block / Area / Locality',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),

                buildAnimatedItem(
                  index: 13,
                  child: CustomTextField(
                    controller: streetController,
                    hintText: "Enter street / locality",
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Country',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),

                buildAnimatedItem(
                  index: 14,
                  child: CustomTextField(
                    readOnly: true,
                    controller: countryController,
                    hintText: "Country",
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'State',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),

                buildAnimatedItem(
                  index: 15,
                  child: CustomTextField(
                    readOnly: true,
                    controller: stateController,
                    hintText: "State",
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Postal Code',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),

                buildAnimatedItem(
                  index: 16,
                  child: CustomTextField(
                    readOnly: true,
                    controller: postalController,
                    hintText: "Postal Code",
                  ),
                ),

                const SizedBox(height: 15),

                buildAnimatedItem(
                  index: 17,
                  child: Opacity(
                    opacity: isServiceAvailable ? 1.0 : 0.6,
                    child: CustomButtonWidget(
                      onPressed: () async {
                        if (!isServiceAvailable) {
                          showCustomSnackBar(
                              "Service not available in this region");
                          return;
                        }

                        if (streetController.text.trim().isEmpty) {
                          showCustomSnackBar("Please enter street");
                          return;
                        }

                        if (stateController.text.trim().isEmpty) {
                          showCustomSnackBar("Please enter state");
                          return;
                        }

                        if (postalController.text.trim().isEmpty) {
                          showCustomSnackBar("Please enter zip/postal code");
                          return;
                        }

                        if (countryController.text.trim().isEmpty) {
                          showCustomSnackBar("Please enter country");
                          return;
                        }

                        if (houseController.text.trim().isEmpty) {
                          showCustomSnackBar("Please enter house number");
                          return;
                        }

                        if (floorController.text.trim().isEmpty) {
                          showCustomSnackBar("Please enter floor number");
                          return;
                        }

                        if (addressType.trim().isEmpty) {
                          showCustomSnackBar("Please select address type");
                          return;
                        }

                        AddressData newAddress = AddressData(
                          id: 0,
                          userId: "",
                          lat: _selectedLatLng.latitude,
                          lon: _selectedLatLng.longitude,
                          city: city.isEmpty ? mapController.text : city,
                          street: streetController.text.trim(),
                          zipCode: postalController.text.trim(),
                          country: countryController.text.trim(),
                          address:
                              "${houseController.text.trim()},${floorController.text.trim()},${streetController.text.trim()},${city.trim()},${stateController.text.trim()},${postalController.text.trim()}",
                          createdAt: DateTime.now().toString(),
                          updatedAt: DateTime.now().toString(),
                          addressType: addressType,
                          contactPersonName:
                              "${Get.find<DashBoardController>().userModel.firstName ?? ''} "
                              "${Get.find<DashBoardController>().userModel.lastName ?? ''}",
                          contactPersonNumber:
                              Get.find<DashBoardController>().userModel.phone,
                          addressLabel: addressType,
                          zoneId:
                              Get.find<DashBoardController>().zoneIdForBooking,
                          isGuest: false,
                          house: houseController.text.trim(),
                          floor: floorController.text.trim(),
                        );

                        try {
                          showLoading();

                          final dashController =
                              Get.find<DashBoardController>();

                          await dashController.addAddress(newAddress);
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          await dashController.getAddressLists();

                          final addresses = dashController.addressResponse.data;

                          /// immediately fill the newly added address in service address field
                          setState(() {
                            _selectedLatLng =
                                LatLng(newAddress.lat, newAddress.lon);

                            dashController.addressController.text =
                                newAddress.address;

                            city = newAddress.city;
                            country = newAddress.country;
                            street = newAddress.street;
                            postalCode = newAddress.zipCode;

                            houseController.text = newAddress.house;
                            floorController.text = newAddress.floor;
                            streetController.text = newAddress.street;
                            countryController.text = newAddress.country;
                            postalController.text = newAddress.zipCode;
                          });

                          /// try matching saved object from API response
                          AddressData? matchedAddress;
                          try {
                            matchedAddress =
                                addresses.cast<AddressData?>().firstWhere(
                                      (a) =>
                                          a != null &&
                                          a.lat == newAddress.lat &&
                                          a.lon == newAddress.lon &&
                                          (a.house ?? "") ==
                                              (newAddress.house ?? "") &&
                                          (a.floor ?? "") ==
                                              (newAddress.floor ?? "") &&
                                          (a.street ?? "") ==
                                              (newAddress.street ?? ""),
                                    );
                          } catch (_) {
                            matchedAddress = null;
                          }

                          selectedAddress = matchedAddress ?? newAddress;

                          dashController.updateLatLong(
                            newAddress.lat.toString(),
                            newAddress.lon.toString(),
                          );

                          dashController.update();

                          hideLoading();

                          FocusScope.of(context1).unfocus();

                          if (Navigator.of(context1).canPop()) {
                            Navigator.of(context1).pop();
                          }
                        } catch (e) {
                          hideLoading();
                          debugPrint("Save address error: $e");
                          showCustomSnackBar("Failed to save address");
                        }
                      },
                      // onPressed: () async {
                      //   if (!isServiceAvailable) {
                      //     showCustomSnackBar(
                      //         "Service not available in this region");
                      //     return;
                      //   }
                      //
                      //   if (streetController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter street");
                      //     return;
                      //   }
                      //
                      //   if (stateController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter state");
                      //     return;
                      //   }
                      //
                      //   if (postalController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter zip/postal code");
                      //     return;
                      //   }
                      //
                      //   if (countryController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter country");
                      //     return;
                      //   }
                      //
                      //   if (houseController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter house number");
                      //     return;
                      //   }
                      //
                      //   if (floorController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter floor number");
                      //     return;
                      //   }
                      //
                      //   if (addressType.trim().isEmpty) {
                      //     showCustomSnackBar("Please select address type");
                      //     return;
                      //   }
                      //
                      //   AddressData newAddress = AddressData(
                      //     id: 0,
                      //     userId: "",
                      //     lat: _selectedLatLng.latitude,
                      //     lon: _selectedLatLng.longitude,
                      //     city: city.isEmpty ? mapController.text : city,
                      //     street: streetController.text.trim(),
                      //     zipCode: postalController.text.trim(),
                      //     country: countryController.text.trim(),
                      //     address:
                      //         "${houseController.text.trim()},${floorController.text.trim()},${streetController.text.trim()},${city.trim()},${stateController.text.trim()},${postalController.text.trim()}",
                      //     createdAt: DateTime.now().toString(),
                      //     updatedAt: DateTime.now().toString(),
                      //     addressType: addressType,
                      //     contactPersonName:
                      //         "${Get.find<DashBoardController>().userModel.firstName ?? ''} "
                      //         "${Get.find<DashBoardController>().userModel.lastName ?? ''}",
                      //     contactPersonNumber:
                      //         Get.find<DashBoardController>().userModel.phone,
                      //     addressLabel: addressType,
                      //     zoneId:
                      //         Get.find<DashBoardController>().zoneIdForBooking,
                      //     isGuest: false,
                      //     house: houseController.text.trim(),
                      //     floor: floorController.text.trim(),
                      //   );
                      //
                      //   try {
                      //     showLoading();
                      //
                      //     final dashController =
                      //         Get.find<DashBoardController>();
                      //
                      //     await dashController.addAddress(newAddress);
                      //     await Future.delayed(
                      //         const Duration(milliseconds: 300));
                      //     await dashController.getAddressLists();
                      //
                      //     final addresses = dashController.addressResponse.data;
                      //
                      //     if (addresses.isNotEmpty) {
                      //       final AddressData addedAddress = addresses.last;
                      //
                      //       setState(() {
                      //         selectedAddress = addedAddress;
                      //         _selectedLatLng =
                      //             LatLng(addedAddress.lat, addedAddress.lon);
                      //
                      //         dashController.addressController.text =
                      //             addedAddress.address;
                      //
                      //         city = addedAddress.city;
                      //         country = addedAddress.country;
                      //         street = addedAddress.street;
                      //         postalCode = addedAddress.zipCode;
                      //
                      //         houseController.text = addedAddress.house;
                      //         floorController.text = addedAddress.floor;
                      //         streetController.text = addedAddress.street;
                      //         countryController.text = addedAddress.country;
                      //         postalController.text = addedAddress.zipCode;
                      //       });
                      //
                      //       dashController.updateLatLong(
                      //         addedAddress.lat.toString(),
                      //         addedAddress.lon.toString(),
                      //       );
                      //
                      //       dashController.update();
                      //     }
                      //
                      //     hideLoading();
                      //
                      //     FocusScope.of(context1).unfocus();
                      //
                      //     if (Navigator.of(context1).canPop()) {
                      //       Navigator.of(context1).pop();
                      //     }
                      //   } catch (e) {
                      //     hideLoading();
                      //     debugPrint("Save address error: $e");
                      //     showCustomSnackBar("Failed to save address");
                      //   }
                      // },
                      // onPressed: () async {
                      //   if (!isServiceAvailable) {
                      //     showCustomSnackBar(
                      //         "Service not available in this region");
                      //     return;
                      //   }
                      //
                      //   if (streetController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter street");
                      //     return;
                      //   }
                      //
                      //   if (stateController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter state");
                      //     return;
                      //   }
                      //
                      //   if (postalController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter zip/postal code");
                      //     return;
                      //   }
                      //
                      //   if (countryController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter country");
                      //     return;
                      //   }
                      //
                      //   if (houseController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter house number");
                      //     return;
                      //   }
                      //
                      //   if (floorController.text.trim().isEmpty) {
                      //     showCustomSnackBar("Please enter floor number");
                      //     return;
                      //   }
                      //
                      //   if (addressType.trim().isEmpty) {
                      //     showCustomSnackBar("Please select address type");
                      //     return;
                      //   }
                      //
                      //   AddressData newAddress = AddressData(
                      //     id: 0,
                      //     userId: "",
                      //     lat: _selectedLatLng.latitude,
                      //     lon: _selectedLatLng.longitude,
                      //     city: city.isEmpty ? mapController.text : city,
                      //     street: streetController.text.trim(),
                      //     zipCode: postalController.text.trim(),
                      //     country: countryController.text.trim(),
                      //     address:
                      //         "${houseController.text.trim()},${floorController.text.trim()},${streetController.text.trim()},${city.trim()},${stateController.text.trim()},${postalController.text.trim()}",
                      //     createdAt: DateTime.now().toString(),
                      //     updatedAt: DateTime.now().toString(),
                      //     addressType: addressType,
                      //     contactPersonName:
                      //         "${Get.find<DashBoardController>().userModel.firstName ?? ''} "
                      //         "${Get.find<DashBoardController>().userModel.lastName ?? ''}",
                      //     contactPersonNumber:
                      //         Get.find<DashBoardController>().userModel.phone,
                      //     addressLabel: addressType,
                      //     zoneId:
                      //         Get.find<DashBoardController>().zoneIdForBooking,
                      //     isGuest: false,
                      //     house: houseController.text.trim(),
                      //     floor: floorController.text.trim(),
                      //   );
                      //
                      //   await Get.find<DashBoardController>()
                      //       .addAddress(newAddress);
                      //   await Future.delayed(const Duration(milliseconds: 300));
                      //   await Get.find<DashBoardController>().getAddressLists();
                      //
                      //   FocusScope.of(context1).unfocus();
                      //
                      //   if (Navigator.of(context1).canPop()) {
                      //     Navigator.of(context1).pop();
                      //   }
                      // },
                      buttonText: 'Save Address',
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                //
                // buildAnimatedItem(
                //   index: 17,
                //   child: Opacity(
                //     opacity: isServiceAvailable ? 1.0 : 0.6,
                //     child: IgnorePointer(
                //       ignoring: !isServiceAvailable,
                //       child: CustomButtonWidget(
                //         onPressed: () async {
                //           if (!isServiceAvailable) {
                //             showCustomSnackBar(
                //               "Service not available in this region",
                //             );
                //             return;
                //           }
                //
                //           if (streetController.text.trim().isEmpty) {
                //             showCustomSnackBar("Please enter street");
                //             return;
                //           }
                //
                //           if (stateController.text.trim().isEmpty) {
                //             showCustomSnackBar("Please enter state");
                //             return;
                //           }
                //
                //           if (postalController.text.trim().isEmpty) {
                //             showCustomSnackBar(
                //               "Please enter zip/postal code",
                //             );
                //             return;
                //           }
                //
                //           if (countryController.text.trim().isEmpty) {
                //             showCustomSnackBar("Please enter country");
                //             return;
                //           }
                //
                //           if (houseController.text.trim().isEmpty) {
                //             showCustomSnackBar("Please enter house number");
                //             return;
                //           }
                //
                //           if (floorController.text.trim().isEmpty) {
                //             showCustomSnackBar("Please enter floor number");
                //             return;
                //           }
                //
                //           if (addressType.trim().isEmpty) {
                //             showCustomSnackBar("Please select address type");
                //             return;
                //           }
                //
                //           AddressData newAddress = AddressData(
                //             id: 0,
                //             userId: "",
                //             lat: _selectedLatLng.latitude,
                //             lon: _selectedLatLng.longitude,
                //             city: city.isEmpty ? mapController.text : city,
                //             street: streetController.text.trim(),
                //             zipCode: postalController.text.trim(),
                //             country: countryController.text.trim(),
                //             address:
                //             "${houseController.text.trim()},${floorController.text.trim()},${streetController.text.trim()},${city.trim()},${stateController.text.trim()},${postalController.text.trim()}",
                //             createdAt: DateTime.now().toString(),
                //             updatedAt: DateTime.now().toString(),
                //             addressType: addressType,
                //             contactPersonName:
                //             "${Get.find<DashBoardController>().userModel.firstName ?? ''} "
                //                 "${Get.find<DashBoardController>().userModel.lastName ?? ''}",
                //             contactPersonNumber:
                //             Get.find<DashBoardController>().userModel.phone,
                //             addressLabel: addressType,
                //             zoneId: Get.find<DashBoardController>()
                //                 .zoneIdForBooking,
                //             isGuest: false,
                //             house: houseController.text.trim(),
                //             floor: floorController.text.trim(),
                //           );
                //
                //           await Get.find<DashBoardController>()
                //               .addAddress(newAddress)
                //               .then((value) async {
                //             await Future.delayed(
                //               const Duration(milliseconds: 300),
                //             );
                //             await Get.find<DashBoardController>()
                //                 .getAddressLists();
                //
                //             Get.back();
                //           });
                //         },
                //         buttonText: 'Save Address',
                //         width: MediaQuery.of(context).size.width - 40,
                //       ),
                //     ),
                //   ),
                // ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget buildGoogleMapWithDetailsDialog(BuildContext context1) {
  //   return StatefulBuilder(
  //     builder: (context, setState) {
  //       return SafeArea(
  //         child: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               const SizedBox(height: 15),
  //               Row(
  //                 children: [
  //                   IconButton(
  //                       onPressed: () {
  //                         Get.back();
  //                       },
  //                       icon: const Icon(Icons.arrow_back,
  //                           size: 30, color: Colors.black)),
  //                   Text(
  //                     "Add Address",
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               buildAnimatedItem(
  //                 index: 10,
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       borderRadius:
  //                           const BorderRadius.all(Radius.circular(10)),
  //                       color: Colors.white,
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.grey.withOpacity(0.2),
  //                           spreadRadius: 5,
  //                           blurRadius: 7,
  //                           offset: const Offset(0, 3),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Column(
  //                         children: [
  //                           GestureDetector(
  //                             onVerticalDragUpdate: (_) {},
  //                             child: SizedBox(
  //                               height: 200,
  //                               child: Stack(
  //                                 children: [
  //                                   GoogleMap(
  //                                     initialCameraPosition: CameraPosition(
  //                                       target: _selectedLatLng,
  //                                       zoom: 15,
  //                                     ),
  //                                     onMapCreated: (controller) {
  //                                       _mapController = controller;
  //                                     },
  //                                     onCameraMove: (position) {
  //                                       setState(() =>
  //                                           _selectedLatLng = position.target);
  //                                     },
  //                                     onCameraIdle: () async {
  //                                       List<Placemark> placemarks =
  //                                           await placemarkFromCoordinates(
  //                                         _selectedLatLng.latitude,
  //                                         _selectedLatLng.longitude,
  //                                       );
  //                                       Placemark place = placemarks.first;
  //                                       setState(() {
  //                                         floorController.text = "";
  //                                         houseController.text = "";
  //                                         streetController.text = "";
  //                                         mapController.text =
  //                                             "${place.street}, ${place.locality}, ${place.country}";
  //                                         city = place.locality ?? "";
  //                                         state =
  //                                             place.administrativeArea ?? "";
  //                                         country = place.country ?? "";
  //                                         street = place.street ?? "";
  //                                         postalCode = place.postalCode ?? "";
  //
  //                                         // streetController.text =
  //                                         //     place.street ?? "";
  //                                         stateController.text =
  //                                             place.administrativeArea ?? "";
  //                                         countryController.text =
  //                                             place.country ?? "";
  //                                         postalController.text =
  //                                             place.postalCode ?? "";
  //                                       });
  //
  //                                       Get.find<DashBoardController>()
  //                                           .updateLatLong(
  //                                         _selectedLatLng.latitude.toString(),
  //                                         _selectedLatLng.longitude.toString(),
  //                                       );
  //                                     },
  //                                     gestureRecognizers: {
  //                                       Factory<OneSequenceGestureRecognizer>(
  //                                           () => EagerGestureRecognizer()),
  //                                     },
  //                                   ),
  //                                   const Center(
  //                                     child: Icon(Icons.location_pin,
  //                                         size: 40, color: Colors.red),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(height: 15),
  //                           GooglePlaceAutoCompleteTextField(
  //                             focusNode: mapFocus,
  //                             textEditingController: mapController,
  //                             googleAPIKey:
  //                                 "AIzaSyBLI5I6o95GqluNuRh0YT3zRj5yqoix8zA",
  //                             inputDecoration: InputDecoration(
  //                               hintText: "Search location",
  //                               fillColor: Colors.white,
  //                               filled: true,
  //                               border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(10)),
  //                             ),
  //                             debounceTime: 600,
  //                             itemClick: (prediction) {
  //                               double lat =
  //                                   double.parse(prediction.lat ?? "0.0");
  //                               double lng =
  //                                   double.parse(prediction.lng ?? "0.0");
  //                               setState(() {
  //                                 _selectedLatLng = LatLng(lat, lng);
  //                               });
  //                               _mapController?.animateCamera(
  //                                   CameraUpdate.newLatLng(_selectedLatLng));
  //                             },
  //                             getPlaceDetailWithLatLng: (prediction) async {
  //                               double lat =
  //                                   double.parse(prediction.lat ?? "0.0");
  //                               double lng =
  //                                   double.parse(prediction.lng ?? "0.0");
  //                               setState(() {
  //                                 _selectedLatLng = LatLng(lat, lng);
  //                               });
  //                               _mapController?.animateCamera(
  //                                   CameraUpdate.newLatLng(_selectedLatLng));
  //                             },
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 15),
  //               buildAnimatedItem(
  //                 index: 9,
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const Text("Address Type",
  //                         style: TextStyle(
  //                             fontSize: 18, fontWeight: FontWeight.bold)),
  //                     Row(
  //                       children: [
  //                         Radio<String>(
  //                           value: "home",
  //                           groupValue: addressType,
  //                           onChanged: (value) =>
  //                               setState(() => addressType = value!),
  //                         ),
  //                         const Text("Home"),
  //                         Radio<String>(
  //                           value: "office",
  //                           groupValue: addressType,
  //                           onChanged: (value) =>
  //                               setState(() => addressType = value!),
  //                         ),
  //                         const Text("Office"),
  //                         Radio<String>(
  //                           value: "other",
  //                           groupValue: addressType,
  //                           onChanged: (value) =>
  //                               setState(() => addressType = value!),
  //                         ),
  //                         const Text("Other"),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: 15),
  //               buildAnimatedItem(
  //                   index: 11,
  //                   child: CustomTextField(
  //                       controller: houseController, hintText: "House No.")),
  //               const SizedBox(height: 15),
  //               buildAnimatedItem(
  //                   index: 12,
  //                   child: CustomTextField(
  //                       controller: floorController, hintText: "Floor")),
  //               const SizedBox(height: 15),
  //               buildAnimatedItem(
  //                   index: 13,
  //                   child: CustomTextField(
  //                       controller: streetController,
  //                       hintText: "Street/Block/Area/Locality")),
  //               const SizedBox(height: 15),
  //               buildAnimatedItem(
  //                   index: 14,
  //                   child: CustomTextField(
  //                       controller: countryController, hintText: "Country")),
  //               const SizedBox(height: 15),
  //               buildAnimatedItem(
  //                   index: 15,
  //                   child: CustomTextField(
  //                       controller: stateController, hintText: "State")),
  //               const SizedBox(height: 15),
  //               buildAnimatedItem(
  //                   index: 16,
  //                   child: CustomTextField(
  //                       controller: postalController, hintText: "Postal Code")),
  //               const SizedBox(height: 15),
  //               buildAnimatedItem(
  //                 index: 17,
  //                 child: CustomButtonWidget(
  //                   onPressed: () async {
  //                     if (streetController.text.trim().isEmpty) {
  //                       showCustomSnackBar("Please enter street");
  //                       return;
  //                     }
  //
  //                     if (stateController.text.trim().isEmpty) {
  //                       showCustomSnackBar("Please enter state");
  //                       return;
  //                     }
  //
  //                     if (postalController.text.trim().isEmpty) {
  //                       showCustomSnackBar("Please enter zip/postal code");
  //                       return;
  //                     }
  //
  //                     if (countryController.text.trim().isEmpty) {
  //                       showCustomSnackBar("Please enter country");
  //                       return;
  //                     }
  //
  //                     if (houseController.text.trim().isEmpty) {
  //                       showCustomSnackBar("Please enter house number");
  //                       return;
  //                     }
  //
  //                     if (floorController.text.trim().isEmpty) {
  //                       showCustomSnackBar("Please enter floor number");
  //                       return;
  //                     }
  //
  //                     if (addressType.trim().isEmpty) {
  //                       showCustomSnackBar("Please select address type");
  //                       return;
  //                     }
  //
  //                     AddressData newAddress = AddressData(
  //                       id: 0,
  //                       userId: "",
  //                       lat: _selectedLatLng.latitude,
  //                       lon: _selectedLatLng.longitude,
  //                       city: city.isEmpty ? mapController.text : city,
  //                       street: streetController.text.trim(),
  //                       zipCode: postalController.text.trim(),
  //                       country: countryController.text.trim(),
  //                       address:
  //                           "${houseController.text.trim()},${floorController.text.trim()},${streetController.text.trim()},${city.trim()},${stateController.text.trim()},${postalCode.trim()}",
  //                       createdAt: DateTime.now().toString(),
  //                       updatedAt: DateTime.now().toString(),
  //                       addressType: addressType,
  //                       contactPersonName:
  //                           "${Get.find<DashBoardController>().userModel.firstName ?? ''} "
  //                           "${Get.find<DashBoardController>().userModel.lastName ?? ''}",
  //                       contactPersonNumber:
  //                           Get.find<DashBoardController>().userModel.phone,
  //                       addressLabel: addressType,
  //                       zoneId:
  //                           Get.find<DashBoardController>().zoneIdForBooking,
  //                       isGuest: false,
  //                       house: houseController.text.trim(),
  //                       floor: floorController.text.trim(),
  //                     );
  //
  //                     await Get.find<DashBoardController>()
  //                         .addAddress(newAddress)
  //                         .then(
  //                       (value) async {
  //                         await Future.delayed(Duration(milliseconds: 300));
  //                         await Get.find<DashBoardController>()
  //                             .getAddressLists();
  //                         // .then((_) {
  //                         // Get.back();
  //                         // showAddressChoiceDialog(
  //                         //   context,
  //                         //   Get.find<DashBoardController>()
  //                         //       .addressResponse
  //                         //       .data,
  //                         //   (address) {
  //                         //     Get.find<DashBoardController>()
  //                         //         .selectedAddressLists
  //                         //         .clear();
  //                         //     Get.find<DashBoardController>()
  //                         //         .selectedAddressLists
  //                         //         .add(address);
  //                         //   },
  //                         // );
  //                         // });
  //
  //                         // if (Get.find<DashBoardController>()
  //                         //     .addressResponse
  //                         //     .data
  //                         //     .isNotEmpty) {
  //                         // showAddressChoiceDialog(
  //                         //   context,
  //                         //   Get.find<DashBoardController>()
  //                         //       .addressResponse
  //                         //       .data,
  //                         //   (address) {
  //                         //     Get.find<DashBoardController>()
  //                         //         .selectedAddressLists
  //                         //         .clear();
  //                         //     Get.find<DashBoardController>()
  //                         //         .selectedAddressLists
  //                         //         .add(address);
  //                         // setState(() {
  //                         //   _selectedLatLng = LatLng(
  //                         //     address.lat,
  //                         //     address.lon,
  //                         //   );
  //                         //   addressController.text = address.address;
  //                         //   Get.find<DashBoardController>()
  //                         //       .addressController
  //                         //       .text = address.address;
  //                         //   city = address.city ?? "";
  //                         //   houseController.text = address.house ?? "";
  //                         //   floorController.text = address.floor ?? "";
  //                         //   country = address.country ?? "";
  //                         //   street = address.street ?? "";
  //                         //   postalCode = address.zipCode ?? "";
  //                         //   Get.find<DashBoardController>().update();
  //                         // });
  //                         // showAddNewAddressDialog(context);
  //                         // Get.back();
  //                         // Get.to(BookingScreen());
  //                         // showAddressChoiceDialog(
  //                         //   context,
  //                         //   Get.find<DashBoardController>()
  //                         //       .addressResponse
  //                         //       .data,
  //                         //   (address) {
  //                         //     setState(
  //                         //       () {
  //                         //         _selectedLatLng = LatLng(
  //                         //           address.lat,
  //                         //           address.lon,
  //                         //         );
  //                         //         addressController.text =
  //                         //             address.address;
  //                         //         Get.find<DashBoardController>()
  //                         //             .addressController
  //                         //             .text = address.address;
  //                         //         city = address.city;
  //                         //         houseController.text = address.house;
  //                         //         floorController.text = address.floor;
  //                         //         country = address.country;
  //                         //         street = address.street;
  //                         //         postalCode = address.zipCode;
  //                         //         Get.find<DashBoardController>()
  //                         //             .update();
  //                         //       },
  //                         //     );
  //                         //     showAddNewAddressDialog(context);
  //                         //   },
  //                         // );
  //                         //   },
  //                         // );
  //                         // }
  //                       },
  //                     );
  //
  //                     // Optionally you can uncomment the rest
  //                     // Get.back();
  //                   },
  //                   buttonText: 'Save Address',
  //                   width: MediaQuery.of(context).size.width - 40,
  //                 ),
  //               ),
  //               const SizedBox(height: 15),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // String selected = 'Online Payment';
  String selected = 'COD';
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Obx(() {
          if (dashboardController.createBookingLoader.value) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DotWaveLoader(
                      text: "Booking is in Progress, Please wait!",
                    ),
                  ],
                ),
              ),
            );
          }

          final media = MediaQuery.of(context);
          final shortest = media.size.shortestSide;
          final isTablet = shortest >= 600;
          final isLandscape = media.orientation == Orientation.landscape;

          final horizontalPadding = isTablet
              ? 24.0
              : isLandscape
                  ? 12.0
                  : 16.0;

          final maxContentWidth = isTablet ? 760.0 : double.infinity;

          return Scaffold(
            backgroundColor: const Color(0xFFF7F9FC),
            resizeToAvoidBottomInset: true,
            bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
                ? null
                : SafeArea(
                    top: false,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        10,
                        horizontalPadding,
                        14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.withOpacity(0.12),
                          ),
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: _buildBottomActionBar(context),
                      ),
                    ),
                  ),
            body: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        /// Header
                        buildAnimatedItem(
                          index: 0,
                          child: _buildBookingHeader(context),
                        ),

                        const SizedBox(height: 18),

                        /// Step Indicator
                        _buildStepIndicator(
                          currentStep: _currentStep,
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 18),

                        /// Step Content
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeOutCubic,
                          child: _buildCurrentStepContent(
                            context,
                            isTablet: isTablet,
                            key: ValueKey(_currentStep),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    if (_currentStep == 2) {
      return buildAnimatedItem(
        index: 22,
        child: CustomButtonWidget(
          onPressed: () async {
            final name =
                "${Get.find<DashBoardController>().userModel.firstName} ${Get.find<DashBoardController>().userModel.lastName}";
            var mobile = Get.find<DashBoardController>().userModel.phone;
            if (mobile.startsWith("+91")) {
              mobile = mobile.substring(3);
            }
            final email = Get.find<DashBoardController>().userModel.email;
            final address =
                Get.find<DashBoardController>().addressController.text.trim();
            final message = messageController.text.trim();

            final dashController = Get.find<DashBoardController>();
            if (!_validateAllFields(
              name: name,
              mobile: mobile,
              email: email,
              address: addressController.text,
              selectedLatLng: _selectedLatLng,
              zoneId: dashController.zoneIdForBooking,
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              city: stateController.text.trim(),
              postalCode: postalController.text.trim(),
              country: countryController.text.trim(),
              street: streetController.text.trim(),
              addressType: addressType,
              selectedVariations: dashController.selectedVariations,
              assignCustomerName: assignNameController.text.trim(),
              assignCustomerPhone: assignPhoneController.text.trim(),
              assignCustomerEmail: assignEmailController.text.trim(),
            )) return;

            // if (selected == "COD") {
            //   dashboardController.createBookingLoader.value = true;
            //   log("rrrr Date date date: ${DateConverter.dateTimeForCoupon(selectedDate).toString()}");
            //   log("rrrr Date date time: ${formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString()}");
            //   await dashController.postOrder({
            //     "name": name,
            //     "mobile_number": mobile,
            //     "address_label": addressType.toString(),
            //     "email": email,
            //     "address": address,
            //     "lat": _selectedLatLng.latitude,
            //     "lng": _selectedLatLng.longitude,
            //     "zone_id": dashController.zoneIdForBooking,
            //     "message": message,
            //     "date":
            //         DateConverter.dateTimeForCoupon(selectedDate).toString(),
            //     "time": formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now())
            //         .toString(),
            //     "payment_method": getPaymentMethodForApi(),
            //     "city": city,
            //     "zip_code": postalCode,
            //     "country": country,
            //     "street": street,
            //     "service_preference": servicePreference,
            //     "assign_customer_name": assignNameController.text.trim(),
            //     "assign_customer_phone": assignPhoneController.text.trim(),
            //     "assign_customer_email": assignEmailController.text.trim(),
            //   }, dashController.selectedVariations, showLoader: false);
            //
            //   await dashController.getCartListing(
            //     limit: "100",
            //     offset: "1",
            //     isRoute: false,
            //     showLoader: false,
            //   );
            //
            //   dashboardController.createBookingLoader.value = false;
            // }
            if (selected == "COD") {
              try {
                dashboardController.createBookingLoader.value = true;

                final success = await dashController.postOrder(
                  {
                    "name": name,
                    "mobile_number": mobile,
                    "address_label": addressType.toString(),
                    "email": email,
                    "address": address,
                    "lat": _selectedLatLng.latitude,
                    "lng": _selectedLatLng.longitude,
                    "zone_id": dashController.zoneIdForBooking,
                    "message": message,
                    "date": DateConverter.dateTimeForCoupon(selectedDate)
                        .toString(),
                    "time":
                        formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now())
                            .toString(),
                    "payment_method": getPaymentMethodForApi(),
                    "city": city,
                    "zip_code": postalCode,
                    "country": country,
                    "street": street,
                    "service_preference": servicePreference,
                    "assign_customer_name": assignNameController.text.trim(),
                    "assign_customer_phone": assignPhoneController.text.trim(),
                    "assign_customer_email": assignEmailController.text.trim(),
                    "house": houseController.text.trim(),
                    "floor": floorController.text.trim(),
                  },
                  dashController.selectedVariations,
                  showLoader: false,
                );

                if (success) {
                  await dashController.getCartListing(
                    limit: "100",
                    offset: "1",
                    isRoute: false,
                    showLoader: false,
                  );

                  dashboardController.createBookingLoader.value = false;

                  Get.offAll(() => const SuccessFullScreen());
                }
              } catch (e) {
                debugPrint("COD booking error: $e");
              } finally {
                dashboardController.createBookingLoader.value = false;
              }
            } else {
              log("Date date date: ${DateConverter.dateTimeForCoupon(selectedDate).toString()}");
              log("Date date time: ${formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString()}");

              makeDigitalPayment(
                isPartial: 0,
                bookingId: '',
                data: {
                  "name": name,
                  "mobile_number": mobile,
                  "address_label": addressType.toString(),
                  "email": email,
                  "address": address,
                  "lat": _selectedLatLng.latitude,
                  "lng": _selectedLatLng.longitude,
                  "zone_id": dashController.zoneIdForBooking,
                  "message": message,
                  "date":
                      DateConverter.dateTimeForCoupon(selectedDate).toString(),
                  "time": formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now())
                      .toString(),
                  "payment_method": "razor_pay",
                  "city": city,
                  "zip_code": postalCode,
                  "country": country,
                  "street": street,
                  "service_preference": servicePreference,
                  "house": houseController.text.trim(),
                  "floor": floorController.text.trim(),
                },
                onPressed: () async {
                  log("Date date date: ${DateConverter.dateTimeForCoupon(selectedDate).toString()}");
                  log("Date date time: ${formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString()}");
                  debugPrint("OnPressed Called====>");
                  await dashController.postOrder({
                    "name": name,
                    "mobile_number": mobile,
                    "address_label": addressType.toString(),
                    "email": email,
                    "address": address,
                    "lat": _selectedLatLng.latitude,
                    "lng": _selectedLatLng.longitude,
                    "zone_id": dashController.zoneIdForBooking,
                    "message": message,
                    "date": DateConverter.dateTimeForCoupon(selectedDate)
                        .toString(),
                    "time":
                        formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now())
                            .toString(),
                    "payment_method": "razor_pay",
                    "city": city,
                    "zip_code": postalCode,
                    "country": country,
                    "street": street,
                    "service_preference": servicePreference
                  }, dashController.selectedVariations, showLoader: true);

                  await dashboardController.getCartListing(
                    limit: "100",
                    offset: "1",
                    isRoute: false,
                    showLoader: true,
                  );
                },
              );
            }
          },
          buttonText: 'Create Booking',
          width: MediaQuery.of(context).size.width - 40,
        ),
      );
    }

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep = _currentStep - 1;
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: const Color(0xFF207FA7).withOpacity(0.30),
                ),
              ),
              child: const Text(
                "Back",
                style: TextStyle(
                  color: Color(0xFF207FA7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              /// STEP 1 VALIDATION
              if (_currentStep == 0) {
                if (selectedDate == null) {
                  _error("Date Required", "Please select booking date");
                  return;
                }

                if (selectedTime == null) {
                  _error("Slot Required", "Please select time slot");
                  return;
                }
              }

              /// STEP 2 VALIDATION
              if (_currentStep == 1) {
                if (assignNameController.text.trim().isEmpty) {
                  _error("Customer Name", "Please enter customer name");
                  return;
                }

                if (!RegExp(r'^[6-9]\d{9}$')
                    .hasMatch(assignPhoneController.text.trim())) {
                  _error("Invalid Phone", "Enter valid 10 digit phone");
                  return;
                }

                if (!GetUtils.isEmail(assignEmailController.text.trim())) {
                  _error("Invalid Email", "Enter valid email address");
                  return;
                }

                if (Get.find<DashBoardController>()
                    .addressController
                    .text
                    .trim()
                    .isEmpty) {
                  _error("Address Required", "Please select address");
                  return;
                }
              }

              setState(() {
                if (_currentStep < 2) {
                  _currentStep++;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF207FA7),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _currentStep == 1 ? "Review Booking" : "Continue",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            Icons.arrow_back,
            size: 25,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        const Text(
          "Book Service",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 25),
      ],
    );
  }

  Widget _buildCurrentStepContent(
    BuildContext context, {
    required bool isTablet,
    Key? key,
  }) {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            _buildSectionCard(
              title: "Step 1 • Schedule Service",
              subtitle: "Choose service type, date and preferred time slot",
              child: Column(
                children: [
                  buildAnimatedItem(
                    index: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Service Preference",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _serviceOption(
                                title: "On-site Service",
                                value: "onsite",
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _serviceOption(
                                title: "Technician Pickup",
                                value: "serviceman_pickup",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  buildAnimatedItem(
                    index: 7,
                    child: Row(
                      children: const [
                        Text(
                          "Select Date",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        DateTime date =
                            DateTime.now().add(Duration(days: index));

                        bool isSelected = selectedDate.year == date.year &&
                            selectedDate.month == date.month &&
                            selectedDate.day == date.day;

                        return _dateCard(date, isSelected);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  buildAnimatedItem(
                    index: 8,
                    child: Row(
                      children: const [
                        Text(
                          "Select Slot",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _generateTimeSlots(selectedDate).map((slot) {
                        bool isSelected = selectedTime != null &&
                            selectedTime!.hour == slot.hour &&
                            selectedTime!.minute == slot.minute;
                        bool isDisabled = !_isSlotEnabled(selectedDate, slot);

                        return Opacity(
                          opacity: isDisabled ? 0.4 : 1.0,
                          child: IgnorePointer(
                            ignoring: isDisabled,
                            child: CustomSelectionWidget(
                              title: _formatTimeOfDay(slot),
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  selectedTime = slot;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 1:
        return Container(
          key: key,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              _buildSectionCard(
                title: "Step 2 • Customer & Address",
                subtitle: "Assign customer details and select service location",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Assign Customer Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: assignNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: "Customer Name",
                        hintText: "Enter full name",
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: assignPhoneController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: "Customer Phone",
                        hintText: "Enter 10 digit number",
                        counterText: "",
                        prefixIcon: const Icon(Icons.phone_android),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length > 12) {
                          assignPhoneController.text = value.substring(0, 12);
                          assignPhoneController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                              offset: assignPhoneController.text.length,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: assignEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Customer Email",
                        hintText: "example@gmail.com",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Service Address",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller:
                          Get.find<DashBoardController>().addressController,
                      hintText: "Select an Address",
                      focusNode: addressFocus,
                      readOnly: true,
                      isEnabled: true,
                      onTap: () async {
                        FocusScope.of(context).unfocus();

                        final dashController = Get.find<DashBoardController>();

                        if (dashController.addressResponse.data.isEmpty) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          );

                          try {
                            await dashController.getAddressLists();
                          } catch (e) {
                            debugPrint("Address list error: $e");
                            Get.snackbar("Error", "Failed to load addresses");
                          } finally {
                            if (mounted &&
                                Navigator.of(context, rootNavigator: true)
                                    .canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          }
                        }
                        //
                        // if (dashController.addressResponse.data.isEmpty) {
                        //   Get.snackbar("No Address", "No saved address found");
                        //   return;
                        // }

                        showAddressChoiceDialog(
                          context,
                          dashController.addressResponse.data,
                          (address) {
                            setState(() {
                              _selectedLatLng =
                                  LatLng(address.lat, address.lon);

                              dashController.addressController.text =
                                  address.address;

                              city = address.city;
                              stateController.text = address.city;
                              houseController.text = address.house;
                              floorController.text = address.floor;
                              postalController.text = address.zipCode;
                              countryController.text = address.country;
                              streetController.text = address.street;

                              country = address.country;
                              street = address.street;
                              postalCode = address.zipCode;
                            });

                            dashController.update();
                          },
                        );
                      },
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: Colors.blue,
                            onPressed: () async {
                              FocusScope.of(context).unfocus();

                              final dashController =
                                  Get.find<DashBoardController>();

                              await dashController.getAddressLists();

                              if (dashController.addressResponse.data.isEmpty) {
                                Get.snackbar(
                                    "No Address", "No saved address found");
                                return;
                              }

                              showAddressChoiceDialog(
                                context,
                                dashController.addressResponse.data,
                                (address) {
                                  setState(() {
                                    _selectedLatLng =
                                        LatLng(address.lat, address.lon);
                                    dashController.addressController.text =
                                        address.address;

                                    city = address.city;
                                    stateController.text = address.city;
                                    houseController.text = address.house;
                                    floorController.text = address.floor;
                                    postalController.text = address.zipCode;
                                    countryController.text = address.country;
                                    streetController.text = address.street;

                                    country = address.country;
                                    street = address.street;
                                    postalCode = address.zipCode;
                                  });

                                  dashController.update();
                                },
                              );
                            }),
                      ),
                    ),
                    // CustomTextField(
                    //   controller:
                    //   Get
                    //       .find<DashBoardController>()
                    //       .addressController,
                    //   hintText: "Select an Address",
                    //   focusNode: addressFocus,
                    //   isEnabled: true,
                    //   readOnly: true,
                    //   onTap: () async {
                    //     await Get.find<DashBoardController>().getAddressLists();
                    //
                    //     showAddressChoiceDialog(
                    //       context,
                    //       Get
                    //           .find<DashBoardController>()
                    //           .addressResponse
                    //           .data,
                    //           (address) {
                    //         setState(() {
                    //           _selectedLatLng =
                    //               LatLng(address.lat, address.lon);
                    //
                    //           final controller = Get.find<
                    //               DashBoardController>();
                    //           controller.addressController.text =
                    //               address.address;
                    //
                    //           city = address.city;
                    //           stateController.text = address.city;
                    //           houseController.text = address.house;
                    //           floorController.text = address.floor;
                    //           postalController.text = address.zipCode;
                    //           countryController.text = address.country;
                    //           streetController.text = address.street;
                    //
                    //           country = address.country;
                    //           street = address.street;
                    //           postalCode = address.zipCode;
                    //         });
                    //
                    //         Get.find<DashBoardController>().update();
                    //       },
                    //     );
                    //
                    //     // showAddressChoiceDialog(
                    //     //   context,
                    //     //   Get.find<DashBoardController>().addressResponse.data,
                    //     //   (address) {
                    //     //     Get.back();
                    //     //
                    //     //     setState(() {
                    //     //       _selectedLatLng =
                    //     //           LatLng(address.lat, address.lon);
                    //     //
                    //     //       final controller =
                    //     //           Get.find<DashBoardController>();
                    //     //       controller.addressController.text =
                    //     //           address.address;
                    //     //
                    //     //       city = address.city;
                    //     //       stateController.text = address.city;
                    //     //       houseController.text = address.house;
                    //     //       floorController.text = address.floor;
                    //     //       postalController.text = address.zipCode;
                    //     //       countryController.text = address.country;
                    //     //       streetController.text = address.street;
                    //     //
                    //     //       country = address.country;
                    //     //       street = address.street;
                    //     //       postalCode = address.zipCode;
                    //     //     });
                    //     //
                    //     //     Get.find<DashBoardController>().update();
                    //     //   },
                    //     // );
                    //   },
                    //   suffixIcon: Container(
                    //     margin: const EdgeInsets.all(6),
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue.withOpacity(0.1),
                    //       shape: BoxShape.circle,
                    //     ),
                    //     child: IconButton(
                    //       icon: const Icon(Icons.edit, size: 20),
                    //       color: Colors.blue,
                    //       onPressed: () async {
                    //         final controller = Get.find<DashBoardController>();
                    //
                    //         try {
                    //           Get.dialog(
                    //             const Center(
                    //                 child: CircularProgressIndicator()),
                    //             barrierDismissible: false,
                    //           );
                    //
                    //           await controller.getAddressLists();
                    //         } finally {
                    //           if (Get.isDialogOpen ?? false) {
                    //             Get.back();
                    //           }
                    //         }
                    //
                    //         if (controller.addressResponse.data.isEmpty) {
                    //           Get.snackbar(
                    //               "No Address", "No saved address found");
                    //           return;
                    //         }
                    //
                    //         showAddressChoiceDialog(
                    //           context,
                    //           controller.addressResponse.data,
                    //               (address) {
                    //             setState(() {
                    //               _selectedLatLng =
                    //                   LatLng(address.lat, address.lon);
                    //
                    //               controller.addressController.text =
                    //                   address.address;
                    //
                    //               city = address.city;
                    //               stateController.text = address.city;
                    //               houseController.text = address.house;
                    //               floorController.text = address.floor;
                    //               postalController.text = address.zipCode;
                    //               countryController.text = address.country;
                    //               streetController.text = address.street;
                    //
                    //               country = address.country;
                    //               street = address.street;
                    //               postalCode = address.zipCode;
                    //             });
                    //
                    //             controller.update();
                    //           },
                    //         );
                    //         // final controller = Get.find<DashBoardController>();
                    //         //
                    //         // Get.dialog(
                    //         //   const Center(child: CircularProgressIndicator()),
                    //         //   barrierDismissible: false,
                    //         // );
                    //         //
                    //         // await controller.getAddressLists();
                    //         //
                    //         // Get.back();
                    //         //
                    //         // if (controller.addressResponse.data.isEmpty) {
                    //         //   Get.snackbar(
                    //         //       "No Address", "No saved address found");
                    //         //   return;
                    //         // }
                    //         //
                    //         // showAddressChoiceDialog(
                    //         //   context,
                    //         //   controller.addressResponse.data,
                    //         //   (address) {
                    //         //     Get.back();
                    //         //
                    //         //     setState(() {
                    //         //       _selectedLatLng =
                    //         //           LatLng(address.lat, address.lon);
                    //         //
                    //         //       controller.addressController.text =
                    //         //           address.address;
                    //         //
                    //         //       city = address.city;
                    //         //       stateController.text = address.city;
                    //         //       houseController.text = address.house;
                    //         //       floorController.text = address.floor;
                    //         //       postalController.text = address.zipCode;
                    //         //       countryController.text = address.country;
                    //         //       streetController.text = address.street;
                    //         //
                    //         //       country = address.country;
                    //         //       street = address.street;
                    //         //       postalCode = address.zipCode;
                    //         //     });
                    //         //
                    //         //     controller.update();
                    //         //   },
                    //         // );
                    //       },
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    if (Get.find<DashBoardController>()
                        .addressController
                        .text
                        .trim()
                        .isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF207FA7).withOpacity(0.10),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF207FA7),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                Get.find<DashBoardController>()
                                    .addressController
                                    .text,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          key: key,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              _buildSectionCard(
                title: "Step 3 • Payment & Review",
                subtitle:
                    "Choose payment method, add notes and confirm booking",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<PaymentMethod>(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            title: const Text("Cash After Service"),
                            value: PaymentMethod.cash_after_service,
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          RadioListTile<PaymentMethod>(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            title: const Text("Online After Service"),
                            value: PaymentMethod.razor_pay,
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    buildAnimatedItem(
                      index: 20,
                      child: Row(
                        children: const [
                          Text(
                            "Any Comment",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildAnimatedItem(
                      index: 21,
                      child: CustomTextField(
                        controller: messageController,
                        hintText: "Write comment here (optional)",
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Booking Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.black.withOpacity(0.55),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        child,
      ],
    );
  }

  Widget _serviceOption({
    required String title,
    required String value,
  }) {
    bool isSelected = servicePreference == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          servicePreference = value;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFF207FA7).withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Color(0xFF207FA7) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Color(0xFF207FA7) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateCard(DateTime date, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
          selectedTime = null;

          log("Select Date: ${selectedDate.toLocal().toString().split(' ')[0]}");
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF207FA7) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF207FA7) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd').format(date),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator({
    required int currentStep,
    required bool isTablet,
  }) {
    const labels = [
      "Schedule",
      "Details",
      "Review",
    ];

    return Row(
      children: List.generate(labels.length, (index) {
        final isActive = index == currentStep;
        final isDone = index < currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: isTablet ? 42 : 38,
                      width: isTablet ? 42 : 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? const Color(0xFF207FA7)
                            : isActive
                                ? const Color(0xFF207FA7)
                                : Colors.white,
                        border: Border.all(
                          color: isActive || isDone
                              ? const Color(0xFF207FA7)
                              : Colors.grey.withOpacity(0.30),
                          width: 1.4,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF207FA7).withOpacity(0.20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color:
                                      isActive ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isActive ? const Color(0xFF207FA7) : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (index != labels.length - 1)
                Container(
                  width: 26,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 18),
                  color: index < currentStep
                      ? const Color(0xFF207FA7)
                      : Colors.grey.withOpacity(0.20),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    final selectedAddress =
        Get.find<DashBoardController>().addressController.text.trim();
    final selectedDateText = DateFormat("dd MMM yyyy").format(selectedDate);
    final selectedTimeText =
        selectedTime == null ? "--" : _formatTimeOfDay(selectedTime!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF207FA7).withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          _buildReviewRow(
            icon: Icons.miscellaneous_services_rounded,
            title: "Service Preference",
            value: servicePreference == "onsite"
                ? "On-site Service"
                : "Technician Pickup",
          ),
          const SizedBox(height: 12),
          _buildReviewRow(
            icon: Icons.calendar_month_rounded,
            title: "Date & Slot",
            value: "$selectedDateText • $selectedTimeText",
          ),
          const SizedBox(height: 12),
          _buildReviewRow(
            icon: Icons.person_outline_rounded,
            title: "Assigned Customer",
            value: assignNameController.text.trim().isEmpty
                ? "--"
                : assignNameController.text.trim(),
          ),
          const SizedBox(height: 12),
          _buildReviewRow(
            icon: Icons.location_on_outlined,
            title: "Address",
            value: selectedAddress.isEmpty ? "--" : selectedAddress,
          ),
          const SizedBox(height: 12),
          _buildReviewRow(
            icon: Icons.payment_rounded,
            title: "Payment",
            value: _paymentMethod == PaymentMethod.cash_after_service
                ? "Cash After Service"
                : "Online After Service",
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey.withOpacity(0.20)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                "Total Payable",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withOpacity(0.60),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                "₹ ${widget.cartTotalPrice}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF207FA7),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF207FA7).withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF207FA7),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
//
// class _StepCardLabel extends StatelessWidget {
//   final String title;
//   final String subtitle;
//
//   const _StepCardLabel({
//     required this.title,
//     required this.subtitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           subtitle,
//           style: TextStyle(
//             fontSize: 12.5,
//             color: Colors.black.withOpacity(0.55),
//           ),
//         ),
//       ],
//     );
//   }
// }

bool _validateAllFields({
  required String name,
  required String mobile,
  required String email,
  required String address,
  required LatLng? selectedLatLng,
  required String? zoneId,
  required DateTime? selectedDate,
  required TimeOfDay? selectedTime,
  required String? city,
  required String? postalCode,
  required String? country,
  required String? street,
  required dynamic addressType,
  required List selectedVariations,

  /// NEW → Assign Customer
  required String assignCustomerName,
  required String assignCustomerPhone,
  required String assignCustomerEmail,
}) {
  /// ASSIGN CUSTOMER VALIDATION

  if (assignCustomerName.trim().isEmpty) {
    _error("Customer Name Required", "Please enter assigned customer name");
    return false;
  }

  if (assignCustomerName.trim().length < 3) {
    _error("Invalid Name", "Customer name must be at least 3 characters");
    return false;
  }

  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(assignCustomerPhone)) {
    _error("Invalid Customer Mobile",
        "Enter valid 10-digit customer mobile number");
    return false;
  }

  if (!GetUtils.isEmail(assignCustomerEmail)) {
    _error("Invalid Customer Email", "Enter valid customer email address");
    return false;
  }

  if (name.trim().isEmpty) {
    _error("Name Required", "Please enter your name");
    return false;
  }

  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
    _error("Invalid Mobile", "Enter a valid 10-digit mobile number");
    return false;
  }

  if (!GetUtils.isEmail(email)) {
    _error("Invalid Email", "Please enter a valid email address");
    return false;
  }

  if (selectedLatLng == null) {
    _error("Location Required", "Please select service location");
    return false;
  }

  // if (zoneId == null || zoneId.isEmpty) {
  //   _error("Zone Error", "Service zone not detected");
  //   return false;
  // }
  final dashboardController = Get.find<DashBoardController>();

  if (zoneId == null || zoneId.isEmpty) {
    zoneId = dashboardController.zoneIdForBooking;
  }
  // if (zoneId == null || zoneId.isEmpty) {
  //   zoneId = "e8554d44-dcf2-47c7-8cf9-400d05a1340f";
  //   // TODO : publishing -> handle zoneID
  //   // Get.snackbar("Zone Error", "Zone ID is missing. Try restarting the app.",
  //   //     backgroundColor: Colors.red, colorText: Colors.white);
  //   // return false;
  // }

  if (selectedDate == null) {
    _error("Date Missing", "Please select booking date");
    return false;
  }

  if (selectedTime == null) {
    _error("Time Missing", "Please select booking time");
    return false;
  }

  if (Get.find<DashBoardController>().addressController.text.trim().isEmpty) {
    _error("Address Required", "Please select address");
    return false;
  }

  if (city == null || city.isEmpty) {
    _error("City Required", "Please enter city");
    return false;
  }

  if (postalCode == null || postalCode.isEmpty) {
    _error("Postal Code Required", "Please enter postal code");
    return false;
  }

  if (country == null || country.isEmpty) {
    _error("Country Required", "Please enter country");
    return false;
  }

  if (street == null || street.isEmpty) {
    _error("Street Required", "Please enter street");
    return false;
  }

  if (addressType == null) {
    _error("Address Type", "Please select address type");
    return false;
  }

  // if (selectedVariations.isEmpty) {
  //   _error("Service Required", "Please select at least one service");
  //   return false;
  // }

  return true;
}

void _error(String title, String message) {
  if (Get.context == null) return;

  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

makeDigitalPayment(
    {required String bookingId,
    required Function? onPressed,
    required Map<String, dynamic> data,
    required int isPartial}) async {
  String url = '';
  SharedPreferences preferences = await SharedPreferences.getInstance();
  ApiClient apiClient = ApiClient(
      appBaseUrl: AppConstants.baseUrl, sharedPreferences: preferences);
  String zoneId = apiClient.mainHeaders['zone_id'] ??
      "e8554d44-dcf2-47c7-8cf9-400d05a1340f";
  String userId = Get.find<DashBoardController>().userModel.id;

  String platform = "app";
  Map<String, dynamic> address = {
    "id": userId,
    "address_type": "service",
    "address_label": "${data["address_label"]}",
    "contact_person_name": "${data["name"]}",
    "contact_person_number": "+91${data["mobile_number"]}",
    "address": "${data["address"]}",
    "lat": "${data["lat"]}",
    "lon": "${data["lng"]}",
    "city": "${data["city"]}",
    "zip_code": "${data["zip_code"]}",
    "country": "${data["country"]}",
    "zone_id": "${data["zone_id"]}",
    "_method": null,
    "street": "${data["street"]}",
    "house": "${data["house"]}",
    "floor": "${data["floor"]}",
    "available_service_count": null
  };
  String userMessage = data["message"] ?? "";
  String encodedAddress = base64Encode(utf8.encode(jsonEncode(address)));
  final combined = '${data["date"]} ${data["time"]}';
  final dateTime = DateTime.parse(combined);

// Format as 'yyyy-MM-dd HH:mm:ss'
  final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  debugPrint("encodedError $encodedAddress");
  url =
      '${AppConstants.baseUrl}payment?payment_method=razor_pay&access_token=${base64Url.encode(utf8.encode(userId))}&zone_id=$zoneId'
      '&service_schedule=${formatted}&service_address_id=null&callback=https://panel.dofix.in&service_address=$encodedAddress&new_user_info=null&message=$userMessage&is_partial=$isPartial&payment_platform=$platform';

  log("url_with_digital_payment:$url");

  await Get.to(() => PaymentScreen(
        url: url,
        fromPage: "switch-payment-method",
        onPressed: onPressed,
        data: data,
      ));
}

// @override
// void initState() {
//   super.initState();
//   Get.find<DashBoardController>().getAddressLists();
// }

// CustomTextField(
// controller: Get.find<DashBoardController>().addressController,
// hintText: "Select an Address",
// focusNode: addressFocus,
// readOnly: true,
// isEnabled: true,
// onTap: () => _openAddressDialog(context),
//
// suffixIcon: Container(
// margin: const EdgeInsets.all(6),
// decoration: BoxDecoration(
// color: Colors.blue.withOpacity(0.1),
// shape: BoxShape.circle,
// ),
// child: IconButton(
// icon: const Icon(Icons.edit, size: 20),
// color: Colors.blue,
// onPressed: () => _openAddressDialog(context),
// ),
// ),
// )

// Future<void> _openAddressDialog(BuildContext context) async {
//   FocusScope.of(context).unfocus();
//
//   final dashController = Get.find<DashBoardController>();
//
//   // Agar address empty hai tabhi API call
//   if (dashController.addressResponse.data.isEmpty) {
//     await dashController.getAddressLists();
//   }
//
//   if (dashController.addressResponse.data.isEmpty) {
//     Get.snackbar("No Address", "No saved address found");
//     return;
//   }
//
//   showAddressChoiceDialog(
//     context,
//     dashController.addressResponse.data,
//         (address) {
//       setState(() {
//         _selectedLatLng = LatLng(address.lat, address.lon);
//
//         dashController.addressController.text = address.address;
//
//         city = address.city;
//         stateController.text = address.city;
//         houseController.text = address.house;
//         floorController.text = address.floor;
//         postalController.text = address.zipCode;
//         countryController.text = address.country;
//         streetController.text = address.street;
//
//         country = address.country;
//         street = address.street;
//         postalCode = address.zipCode;
//       });
//
//       dashController.update();
//     },
//   );
// }
