import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:do_fix/app/views/PaymentScreen/payment_Screen.dart';
import 'package:do_fix/app/views/services/service_details_screen.dart';
// import 'package:do_fix/app/widgets/custom_payment_method_widget.dart';
import 'package:do_fix/app/widgets/custom_selection_widget.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/utils/common_functions.dart';
import 'package:do_fix/widgets/common_loading.dart';
import 'package:do_fix/widgets/custom_snack_bar.dart';
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
// DashBoardController, DateConverter, formatTimeOfDay24Hour
//use for open razor pay payment getway
// enum PaymentMethod { cash, razor_pay }
enum PaymentMethod { cash_after_service, razor_pay}

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
    dashboardController.createBookingLoader.value = false;
    addressController.text = "";
    streetController.text = "";
    Get.find<DashBoardController>().addressController.text = "";
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await Get.find<DashBoardController>().getUserInfo(false);
        _setInitialLocation();
      },
    );
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  bool isCashPayment() {
    return _paymentMethod == PaymentMethod.cash_after_service;
  }

  String getPaymentMethodForApi() {
    return _paymentMethod == PaymentMethod.cash_after_service
        ? "cash_after_service"
        : "razor_pay";
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
      // showCustomSnackBar("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        hideLoading();
        // showCustomSnackBar("Location services are disabled.");
        return;
      } else if (permission == LocationPermission.denied) {
        hideLoading();
        // showCustomSnackBar("Location services are disabled.");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLatLng = LatLng(position.latitude, position.longitude);
    });
    await _getAddressFromLatLng(LatLng(position.latitude, position.longitude));
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        // addressController.text =
        //     "${place.street}, ${place.locality}, ${place.country}";
        // Get.find<DashBoardController>().addressController.text =
        //     "${place.street}, ${place.locality}, ${place.country}";
        addressController.text = "";
        Get.find<DashBoardController>().addressController.text = "";
        city = place.locality ?? "";
        state = place.administrativeArea ?? "";
        country = place.country ?? "";
        street = place.street ?? "";
        postalCode = place.postalCode ?? "";
        mapController.text =
            "${place.street},${place.locality}, ${place.country}";
        Get.find<DashBoardController>().updateLatLong(
          position.latitude.toString(),
          position.longitude.toString(),
        );
      });
      Get.find<DashBoardController>().update();
      hideLoading();
    } catch (e) {
      print(e);
    }
  }

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
      // Show AlertDialog when list is empty
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("No Saved Addresses"),
            content: const Text("You don't have any saved addresses yet."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showAddNewAddressDialog(context);
                  setState(() {
                    selectedAddress = null;
                  });
                },
                child: const Text("Add New Address"),
              ),
            ],
          );
        },
      );
    } else {
      // Show ModalBottomSheet with StatefulBuilder
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Choose Address",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          // ListTile(
                          //   onTap: () async {
                          //     debugPrint("Use Current Location");
                          //     await _setInitialLocation();
                          //     setState(() {
                          //       debugPrint("Use Current Location setstate");
                          //       selectedAddress = null;
                          //       // Navigator.of(context).pop();
                          //       Get.back();
                          //     });
                          //   },
                          //   leading: Icon(
                          //     selectedAddress != null
                          //         ? Icons.location_searching
                          //         : Icons.my_location,
                          //     color: Colors.blue,
                          //   ),
                          //   title: const Text("Use Current Location"),
                          // ),
                          const Divider(),
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              itemCount: addressList.length,
                              itemBuilder: (context, index) {
                                final address = addressList[index];
                                return RadioListTile<AddressData>(
                                  value: address,
                                  selected: selectedAddress == address,
                                  groupValue: selectedAddress,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAddress = value;
                                    });
                                    onSelectAddress(value!);
                                  },
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "(${CommonFunctions().capitalizeFirstLetter(address.addressLabel)}) ${address.address}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // IconButton(
                                      //   icon: const Icon(Icons.edit,
                                      //       color: Colors.grey),
                                      //   onPressed: () {
                                      //     Navigator.of(context).pop();
                                      //     showAddNewAddressDialog(context);
                                      //   },
                                      // ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              showAddNewAddressDialog(context);
                            },
                            child: const Text("Add New Address"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }
  }

  void showAddNewAddressDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 5,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: buildGoogleMapWithDetailsDialog(context),
      ),
    );
  }

  Widget buildGoogleMapWithDetailsDialog(BuildContext context1) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back,
                            size: 30, color: Colors.black)),
                    Text(
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
                                      onMapCreated: (controller) {
                                        _mapController = controller;
                                      },
                                      onCameraMove: (position) {
                                        setState(() =>
                                            _selectedLatLng = position.target);
                                      },
                                      onCameraIdle: () async {
                                        List<Placemark> placemarks =
                                            await placemarkFromCoordinates(
                                          _selectedLatLng.latitude,
                                          _selectedLatLng.longitude,
                                        );
                                        Placemark place = placemarks.first;
                                        setState(() {
                                          floorController.text = "";
                                          houseController.text = "";
                                          streetController.text = "";
                                          mapController.text =
                                              "${place.street}, ${place.locality}, ${place.country}";
                                          city = place.locality ?? "";
                                          state =
                                              place.administrativeArea ?? "";
                                          country = place.country ?? "";
                                          street = place.street ?? "";
                                          postalCode = place.postalCode ?? "";

                                          // streetController.text =
                                          //     place.street ?? "";
                                          stateController.text =
                                              place.administrativeArea ?? "";
                                          countryController.text =
                                              place.country ?? "";
                                          postalController.text =
                                              place.postalCode ?? "";
                                        });

                                        Get.find<DashBoardController>()
                                            .updateLatLong(
                                          _selectedLatLng.latitude.toString(),
                                          _selectedLatLng.longitude.toString(),
                                        );
                                      },
                                      gestureRecognizers: {
                                        Factory<OneSequenceGestureRecognizer>(
                                            () => EagerGestureRecognizer()),
                                      },
                                    ),
                                    const Center(
                                      child: Icon(Icons.location_pin,
                                          size: 40, color: Colors.red),
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
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              debounceTime: 600,
                              itemClick: (prediction) {
                                double lat =
                                    double.parse(prediction.lat ?? "0.0");
                                double lng =
                                    double.parse(prediction.lng ?? "0.0");
                                setState(() {
                                  _selectedLatLng = LatLng(lat, lng);
                                });
                                _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(_selectedLatLng));
                              },
                              getPlaceDetailWithLatLng: (prediction) async {
                                double lat =
                                    double.parse(prediction.lat ?? "0.0");
                                double lng =
                                    double.parse(prediction.lng ?? "0.0");
                                setState(() {
                                  _selectedLatLng = LatLng(lat, lng);
                                });
                                _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(_selectedLatLng));
                              },
                            ),
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
                      const Text("Address Type",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Radio<String>(
                            value: "home",
                            groupValue: addressType,
                            onChanged: (value) =>
                                setState(() => addressType = value!),
                          ),
                          const Text("Home"),
                          Radio<String>(
                            value: "office",
                            groupValue: addressType,
                            onChanged: (value) =>
                                setState(() => addressType = value!),
                          ),
                          const Text("Office"),
                          Radio<String>(
                            value: "other",
                            groupValue: addressType,
                            onChanged: (value) =>
                                setState(() => addressType = value!),
                          ),
                          const Text("Other"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 11,
                    child: CustomTextField(
                        controller: houseController, hintText: "House No.")),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 12,
                    child: CustomTextField(
                        controller: floorController, hintText: "Floor")),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 13,
                    child: CustomTextField(
                        controller: streetController,
                        hintText: "Street/Block/Area/Locality")),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 14,
                    child: CustomTextField(
                        controller: countryController, hintText: "Country")),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 15,
                    child: CustomTextField(
                        controller: stateController, hintText: "State")),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 16,
                    child: CustomTextField(
                        controller: postalController, hintText: "Postal Code")),
                const SizedBox(height: 15),
                buildAnimatedItem(
                  index: 17,
                  child: CustomButtonWidget(
                    onPressed: () async {
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
                        city: city,
                        street: street,
                        zipCode: postalCode,
                        country: country,
                        address:
                            "${houseController.text.trim()},${floorController.text.trim()},${streetController.text.trim()},${city.trim()},${stateController.text.trim()},${postalCode.trim()}",
                        createdAt: DateTime.now().toString(),
                        updatedAt: DateTime.now().toString(),
                        addressType: addressType,
                        contactPersonName: Get.find<DashBoardController>()
                                .userModel
                                .firstName +
                            " " +
                            Get.find<DashBoardController>().userModel.lastName,
                        contactPersonNumber:
                            Get.find<DashBoardController>().userModel.phone,
                        addressLabel: addressType,
                        zoneId:
                            Get.find<DashBoardController>().zoneIdForBooking,
                        isGuest: false,
                        house: houseController.text.trim(),
                        floor: floorController.text.trim(),
                      );

                      await Get.find<DashBoardController>()
                          .addAddress(newAddress)
                          .then(
                        (value) async {
                          await Future.delayed(Duration(milliseconds: 300));
                          await Get.find<DashBoardController>()
                              .getAddressLists();
                          // .then((_) {
                          // Get.back();
                          // showAddressChoiceDialog(
                          //   context,
                          //   Get.find<DashBoardController>()
                          //       .addressResponse
                          //       .data,
                          //   (address) {
                          //     Get.find<DashBoardController>()
                          //         .selectedAddressLists
                          //         .clear();
                          //     Get.find<DashBoardController>()
                          //         .selectedAddressLists
                          //         .add(address);
                          //   },
                          // );
                          // });

                          // if (Get.find<DashBoardController>()
                          //     .addressResponse
                          //     .data
                          //     .isNotEmpty) {
                          // showAddressChoiceDialog(
                          //   context,
                          //   Get.find<DashBoardController>()
                          //       .addressResponse
                          //       .data,
                          //   (address) {
                          //     Get.find<DashBoardController>()
                          //         .selectedAddressLists
                          //         .clear();
                          //     Get.find<DashBoardController>()
                          //         .selectedAddressLists
                          //         .add(address);
                          // setState(() {
                          //   _selectedLatLng = LatLng(
                          //     address.lat,
                          //     address.lon,
                          //   );
                          //   addressController.text = address.address;
                          //   Get.find<DashBoardController>()
                          //       .addressController
                          //       .text = address.address;
                          //   city = address.city ?? "";
                          //   houseController.text = address.house ?? "";
                          //   floorController.text = address.floor ?? "";
                          //   country = address.country ?? "";
                          //   street = address.street ?? "";
                          //   postalCode = address.zipCode ?? "";
                          //   Get.find<DashBoardController>().update();
                          // });
                          // showAddNewAddressDialog(context);
                          // Get.back();
                          // Get.back();
                          // Get.to(BookingScreen());
                          // showAddressChoiceDialog(
                          //   context,
                          //   Get.find<DashBoardController>()
                          //       .addressResponse
                          //       .data,
                          //   (address) {
                          //     setState(
                          //       () {
                          //         _selectedLatLng = LatLng(
                          //           address.lat,
                          //           address.lon,
                          //         );
                          //         addressController.text =
                          //             address.address;
                          //         Get.find<DashBoardController>()
                          //             .addressController
                          //             .text = address.address;
                          //         city = address.city;
                          //         houseController.text = address.house;
                          //         floorController.text = address.floor;
                          //         country = address.country;
                          //         street = address.street;
                          //         postalCode = address.zipCode;
                          //         Get.find<DashBoardController>()
                          //             .update();
                          //       },
                          //     );
                          //     showAddNewAddressDialog(context);
                          //   },
                          // );
                          //   },
                          // );
                          // }
                        },
                      );

                      // Optionally you can uncomment the rest
                      // Get.back();
                    },
                    buttonText: 'Save Address', width:  MediaQuery.of(context).size.width - 40,
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  // String selected = 'Online Payment';
  String selected = 'COD';

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
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Booking is in Progress, Please wait!",
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildAnimatedItem(
                    index: 22,
                    child: CustomButtonWidget(
                      onPressed: () async {
                        final name = Get.find<DashBoardController>()
                                .userModel
                                .firstName +
                            " " +
                            Get.find<DashBoardController>().userModel.lastName;
                        var mobile =
                            Get.find<DashBoardController>().userModel.phone;
                        if (mobile.startsWith("+91")) {
                          mobile = mobile.substring(3);
                        }
                        final email =
                            Get.find<DashBoardController>().userModel.email;
                        final address = Get.find<DashBoardController>()
                            .addressController
                            .text
                            .trim();
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
                        )) return;
                        if (isCashPayment()) {
                          // showLoading();
                          dashboardController.createBookingLoader.value = true;
                          log("rrrr Date date date: ${DateConverter.dateTimeForCoupon(selectedDate).toString()}");
                          log("rrrr Date date time: ${formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString()}");
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
                            "date":
                                DateConverter.dateTimeForCoupon(selectedDate)
                                    .toString(),
                            "time": formatTimeOfDay24Hour(
                                    selectedTime ?? TimeOfDay.now())
                                .toString(),
                            "payment_method": getPaymentMethodForApi(),
                            "city": city,
                            "zip_code": postalCode,
                            "country": country,
                            "street": street,
                            "service_preference": servicePreference
                          }, dashController.selectedVariations,
                              showLoader: false);
                          await dashController.getCartListing(
                              limit: "100",
                              offset: "1",
                              isRoute: false,
                              showLoader: false);
                          dashboardController.createBookingLoader.value = false;
                          // hideLoading();
                          // log("Date date date: ${DateConverter.dateTimeForCoupon(selectedDate).toString()}");
                          // log("Date date time: ${formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString()}");
                          // // openCheckout();
                          // // return;
                          // makeDigitalPayment(
                          //   isPartial: 0,
                          //   bookingId: '',
                          //   data: {
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
                          //         DateConverter.dateTimeForCoupon(selectedDate)
                          //             .toString(),
                          //     "time": formatTimeOfDay24Hour(
                          //             selectedTime ?? TimeOfDay.now())
                          //         .toString(),
                          //     "payment_method": "razor_pay",
                          //     "city": city,
                          //     "zip_code": postalCode,
                          //     "country": country,
                          //     "street": street,
                          //     "service_preference": servicePreference,
                          //     "house": houseController.text.trim(),
                          //     "floor": floorController.text.trim(),
                          //   },
                          //   onPressed: () {
                          //     log("Date date date: ${DateConverter.dateTimeForCoupon(selectedDate).toString()}");
                          //     log("Date date time: ${formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString()}");
                          //     debugPrint("OnPressed Called====>");
                          //     dashController.postOrder({
                          //       "name": name,
                          //       "mobile_number": mobile,
                          //       "address_label": addressType.toString(),
                          //       "email": email,
                          //       "address": address,
                          //       "lat": _selectedLatLng.latitude,
                          //       "lng": _selectedLatLng.longitude,
                          //       "zone_id": dashController.zoneIdForBooking,
                          //       "message": message,
                          //       "date":
                          //           DateConverter.dateTimeForCoupon(selectedDate)
                          //               .toString(),
                          //       "time": formatTimeOfDay24Hour(
                          //               selectedTime ?? TimeOfDay.now())
                          //           .toString(),
                          //       "payment_method": "razor_pay",
                          //       "city": city,
                          //       "zip_code": postalCode,
                          //       "country": country,
                          //       "street": street,
                          //       "service_preference": servicePreference
                          //     }, dashController.selectedVariations);
                          //   },
                          // );
                        } else {
                          log("Date date date: ${DateConverter.dateTimeForCoupon(selectedDate).toString()}");
                          log("Date date time: ${formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString()}");
                          //use for open razorpay payment get way
                          // openCheckout();
                          // return;
                          // makeDigitalPayment(
                          //   isPartial: 0,
                          //   bookingId: '',
                          //   data: {
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
                          //         DateConverter.dateTimeForCoupon(selectedDate)
                          //             .toString(),
                          //     "time": formatTimeOfDay24Hour(
                          //             selectedTime ?? TimeOfDay.now())
                          //         .toString(),
                          //     "payment_method": "razor_pay",
                          //     "city": city,
                          //     "zip_code": postalCode,
                          //     "country": country,
                          //     "street": street,
                          //     "service_preference": servicePreference,
                          //     "house": houseController.text.trim(),
                          //     "floor": floorController.text.trim(),
                          //   },
                          //   onPressed: () async {
                          //     log("Date date date: ${DateConverter.dateTimeForCoupon(selectedDate).toString()}");
                          //     log("Date date time: ${formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString()}");
                          //     debugPrint("OnPressed Called====>");
                          //     await dashController.postOrder({
                          //       "name": name,
                          //       "mobile_number": mobile,
                          //       "address_label": addressType.toString(),
                          //       "email": email,
                          //       "address": address,
                          //       "lat": _selectedLatLng.latitude,
                          //       "lng": _selectedLatLng.longitude,
                          //       "zone_id": dashController.zoneIdForBooking,
                          //       "message": message,
                          //       "date": DateConverter.dateTimeForCoupon(
                          //               selectedDate)
                          //           .toString(),
                          //       "time": formatTimeOfDay24Hour(
                          //               selectedTime ?? TimeOfDay.now())
                          //           .toString(),
                          //       "payment_method": getPaymentMethodForApi(),
                          //       "city": city,
                          //       "zip_code": postalCode,
                          //       "country": country,
                          //       "street": street,
                          //       "service_preference": servicePreference
                          //     }, dashController.selectedVariations,
                          //         showLoader: true);
                          //     await dashboardController.getCartListing(
                          //         limit: "100",
                          //         offset: "1",
                          //         isRoute: false,
                          //         showLoader: true);
                          //   },
                          // );
                          //i use this send only payment method
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
                            "date": DateConverter.dateTimeForCoupon(selectedDate).toString(),
                            "time": formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString(),

                            // 👇 ONLY METHOD INFO
                            "payment_method": _paymentMethod == PaymentMethod.cash_after_service
                                ? "cash_after_service"
                                : "razor_pay",

                            "city": city,
                            "zip_code": postalCode,
                            "country": country,
                            "street": street,
                            "service_preference": servicePreference,
                          }, dashController.selectedVariations,
                              showLoader: true
                          );

                        }
                      },
                      buttonText: 'Create Booking', width:  MediaQuery.of(context).size.width - 40,
                    ),
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    buildAnimatedItem(
                      index: 0,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Icon(
                              Icons.arrow_back,
                              size: 25,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            "Book Service",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    buildAnimatedItem(
                      index: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Service Preference",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              CustomSelectionWidget(
                                title: "On-site Service",
                                isSelected: servicePreference == "onsite",
                                onTap: () {
                                  setState(() {
                                    servicePreference = "onsite";
                                  });
                                },
                              ),
                              SizedBox(width: 12),
                              CustomSelectionWidget(
                                title: "Technician Pickup",
                                isSelected:
                                    servicePreference == "serviceman_pickup",
                                onTap: () {
                                  setState(() {
                                    servicePreference = "serviceman_pickup";
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    buildAnimatedItem(
                      index: 7,
                      child: Row(
                        children: [
                          Text(
                            "Select Date",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          DateTime date =
                              DateTime.now().add(Duration(days: index));
                          bool isSelected = selectedDate.year == date.year &&
                              selectedDate.month == date.month &&
                              selectedDate.day == date.day;
                          return CustomSelectionWidget(
                            title: DateFormat('EEE').format(date),
                            text: DateFormat('dd MMM').format(date),
                            isSelected: isSelected,
                            onTap: () {
                              setState(
                                () {
                                  selectedDate = date;
                                  selectedTime = null;
                                  log("Select Date: ${selectedDate.toLocal().toString().split(' ')[0]}");
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    buildAnimatedItem(
                      index: 8,
                      child: Row(
                        children: [
                          Text(
                            "Select Slot",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _generateTimeSlots(selectedDate).map((slot) {
                            bool isSelected = selectedTime != null &&
                                selectedTime!.hour == slot.hour &&
                                selectedTime!.minute == slot.minute;
                            bool isDisabled =
                                !_isSlotEnabled(selectedDate, slot);

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
                      ],
                    ),
                    SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Method",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<PaymentMethod>(
                                contentPadding: EdgeInsets.zero,
                                title: const Text("Cash After Service"),
                                value: PaymentMethod.cash_after_service,
                                groupValue: _paymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<PaymentMethod>(
                                contentPadding: EdgeInsets.zero,
                                title: const Text("Online After Service"),
                                value: PaymentMethod.razor_pay,
                                groupValue: _paymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    buildAnimatedItem(
                      index: 10,
                      child: Row(
                        children: [
                          Text(
                            "Add Address",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller:
                          Get.find<DashBoardController>().addressController,
                      hintText: "Select an Address",
                      focusNode: addressFocus,
                      isEnabled: true,
                      readOnly: true,
                      onTap: () async {
                        await Get.find<DashBoardController>().getAddressLists();
                        await Future.delayed(Duration(seconds: 1));
                        showAddressChoiceDialog(
                            context,
                            Get.find<DashBoardController>()
                                .addressResponse
                                .data, (address) {
                          setState(() {
                            _selectedLatLng = LatLng(
                              address.lat,
                              address.lon,
                            );
                            addressController.text = address.address;
                            Get.find<DashBoardController>()
                                .addressController
                                .text = address.address;
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
                            Get.find<DashBoardController>().update();
                          });
                          // showAddNewAddressDialog(context);
                          Get.back();
                        });
                      },
                      suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Get.find<DashBoardController>()
                              .getAddressLists();
                          await Future.delayed(Duration(seconds: 1));
                          showAddressChoiceDialog(
                              context,
                              Get.find<DashBoardController>()
                                  .addressResponse
                                  .data, (address) {
                            setState(() {
                              _selectedLatLng = LatLng(
                                address.lat,
                                address.lon,
                              );
                              addressController.text = address.address;
                              Get.find<DashBoardController>()
                                  .addressController
                                  .text = address.address;
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
                              Get.find<DashBoardController>().update();
                            });
                            // showAddNewAddressDialog(context);
                            Get.back();
                          });
                        },
                      ),
                    ),

                    // SizedBox(height: 15),
                    // buildAnimatedItem(
                    //   index: 18,
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         "Add Attachment",
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //       Spacer(),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 15),
                    // buildAnimatedItem(
                    //   index: 19,
                    //   child: CustomTappableOnlyWidget(
                    //     leading: Icon(
                    //       Icons.image_outlined,
                    //       color: grey.withOpacity(0.30),
                    //     ),
                    //     title: "Upload Media",
                    //     onTap: () {},
                    //   ),
                    // ),
                    // SizedBox(height: 15),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     const Text(
                    //       'Payment Type',
                    //       style: TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    // CustomPaymentMethodWidget(
                    //   label:
                    //       'Full Payment - ₹${CommonFunctions().calculatePercentageOfCartTotal(cartTotalPrice: widget.cartTotalPrice, percentage: 100.0)}',
                    //   isSelected: selected == 'Full Payment',
                    //   isEnabled: true,
                    //   onTap: () {
                    //     setState(() {
                    //       selected = 'Full Payment';
                    //     });
                    //   },
                    // ),
                    // CustomPaymentMethodWidget(
                    //   label:
                    //       'Partial Payment - ₹${CommonFunctions().calculatePercentageOfCartTotal(cartTotalPrice: widget.cartTotalPrice, percentage: bookingController.partialPaymentPercentage.value)}',
                    //   isSelected: selected == 'Partial Payment',
                    //   isEnabled: true,
                    //   onTap: () {
                    //     setState(() {
                    //       selected = 'Partial Payment';
                    //     });
                    //   },
                    // ),
                    // CustomPaymentMethodWidget(
                    //   label: 'Cash on Delivery',
                    //   isSelected: selected == 'COD',
                    //   isEnabled: true,
                    //   onTap: () {
                    //     setState(() {
                    //       selected = 'COD';
                    //     });
                    //   },
                    // ),
                    // CustomPaymentMethodWidget(
                    //   label: 'Credit card/ Debit card/ Net banking/ UPI',
                    //   isSelected: selected == 'Online Payment',
                    //   isEnabled: true,
                    //   onTap: () {
                    //     setState(() {
                    //       selected = 'Online Payment';
                    //     });
                    //   },
                    // ),
                    //   ],
                    // ),
                    const SizedBox(height: 15),
                    buildAnimatedItem(
                      index: 20,
                      child: Row(
                        children: [
                          Text(
                            "Any Comment",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    buildAnimatedItem(
                      index: 21,
                      child: CustomTextField(
                        controller: messageController,
                        hintText: "Write comment here",
                      ),
                    ),
                    // const SizedBox(height: 20),
                    // buildAnimatedItem(
                    //   index: 22,
                    //   child: CustomButtonWidget(
                    //     onPressed: () async {
                    //       final name = Get.find<DashBoardController>()
                    //               .userModel
                    //               .firstName +
                    //           " " +
                    //           Get.find<DashBoardController>().userModel.lastName;
                    //       var mobile =
                    //           Get.find<DashBoardController>().userModel.phone;
                    //       if (mobile.startsWith("+91")) {
                    //         mobile = mobile.substring(3);
                    //       }
                    //       final email =
                    //           Get.find<DashBoardController>().userModel.email;
                    //       final address = Get.find<DashBoardController>()
                    //           .addressController
                    //           .text
                    //           .trim();
                    //       final message = messageController.text.trim();

                    //       final dashController = Get.find<DashBoardController>();
                    //       if (!_validateAllFields(
                    //         name: name,
                    //         mobile: mobile,
                    //         email: email,
                    //         address: address,
                    //         selectedLatLng: _selectedLatLng,
                    //         zoneId: dashController.zoneIdForBooking,
                    //         selectedDate: selectedDate,
                    //         selectedTime: selectedTime,
                    //         city: city,
                    //         postalCode: postalCode,
                    //         country: country,
                    //         street: street,
                    //         addressType: addressType,
                    //         selectedVariations: dashController.selectedVariations,
                    //       )) return;

                    //       // Show Bottom Sheet for Payment Method Selection
                    //       final selectedPaymentMethod =
                    //           await showModalBottomSheet<String>(
                    //         context: context,
                    //         shape: const RoundedRectangleBorder(
                    //           borderRadius:
                    //               BorderRadius.vertical(top: Radius.circular(16)),
                    //         ),
                    //         builder: (_) => Column(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             ListTile(
                    //               leading: Icon(Icons.money),
                    //               title: Text("Cash on Delivery"),
                    //               onTap: () {
                    //                 dashController.postOrder({
                    //                   "name": name,
                    //                   "mobile_number": mobile,
                    //                   "address_label": addressType.toString(),
                    //                   "email": email,
                    //                   "address": address,
                    //                   "lat": _selectedLatLng.latitude,
                    //                   "lng": _selectedLatLng.longitude,
                    //                   "zone_id": dashController.zoneIdForBooking,
                    //                   "message": message,
                    //                   "date": DateConverter.dateTimeForCoupon(
                    //                           selectedDate)
                    //                       .toString(),
                    //                   "time": formatTimeOfDay24Hour(
                    //                           selectedTime ?? TimeOfDay.now())
                    //                       .toString(),
                    //                   "payment_method": "cash_after_service",
                    //                   "city": city,
                    //                   "zip_code": postalCode,
                    //                   "country": country,
                    //                   "street": street,
                    //                   "service_preference": servicePreference
                    //                 }, dashController.selectedVariations);
                    //               },
                    //             ),
                    //             ListTile(
                    //               leading: Icon(Icons.payment),
                    //               title: Text("Online Payment"),
                    //               onTap: () {
                    //                 makeDigitalPayment(
                    //                   bookingId: '',
                    //                   data: {
                    //                     "name": name,
                    //                     "mobile_number": mobile,
                    //                     "address_label": addressType.toString(),
                    //                     "email": email,
                    //                     "address": address,
                    //                     "lat": _selectedLatLng.latitude,
                    //                     "lng": _selectedLatLng.longitude,
                    //                     "zone_id": dashController.zoneIdForBooking,
                    //                     "message": message,
                    //                     "date": DateConverter.dateTimeForCoupon(
                    //                             selectedDate)
                    //                         .toString(),
                    //                     "time": formatTimeOfDay24Hour(
                    //                             selectedTime ?? TimeOfDay.now())
                    //                         .toString(),
                    //                     "payment_method": "razor_pay",
                    //                     "city": city,
                    //                     "zip_code": postalCode,
                    //                     "country": country,
                    //                     "street": street,
                    //                     "service_preference": servicePreference
                    //                   },
                    //                   onPressed: () {
                    //                     debugPrint("OnPressed Called====>");
                    //                     dashController.postOrder({
                    //                       "name": name,
                    //                       "mobile_number": mobile,
                    //                       "address_label": addressType.toString(),
                    //                       "email": email,
                    //                       "address": address,
                    //                       "lat": _selectedLatLng.latitude,
                    //                       "lng": _selectedLatLng.longitude,
                    //                       "zone_id":
                    //                           dashController.zoneIdForBooking,
                    //                       "message": message,
                    //                       // can be empty or null
                    //                       "date": DateConverter.dateTimeForCoupon(
                    //                               selectedDate)
                    //                           .toString(),
                    //                       "time": formatTimeOfDay24Hour(
                    //                               selectedTime ?? TimeOfDay.now())
                    //                           .toString(),
                    //                       "payment_method": "razor_pay",
                    //                       "city": city,
                    //                       "zip_code": postalCode,
                    //                       "country": country,
                    //                       "street": street,
                    //                       "service_preference": servicePreference
                    //                     }, dashController.selectedVariations);
                    //                   },
                    //                 );
                    //               },
                    //             ),
                    //             const SizedBox(
                    //               height: 40,
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     },
                    //     buttonText: 'Book Now',
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

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
}) {
  print(
      "All fields: $name, $mobile, $email, $address, $city, $postalCode, $country, $street, $addressType");

  if (!GetUtils.isEmail(email)) {
    Get.snackbar("Invalid Email", "Please enter a valid email address.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }

  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
    Get.snackbar("Invalid Mobile", "Enter a valid 10-digit mobile number.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }

  if (selectedLatLng == null) {
    Get.snackbar("Location Required", "Please select a location on the map.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }

  if (zoneId == null || zoneId.isEmpty) {
    zoneId = "e8554d44-dcf2-47c7-8cf9-400d05a1340f";
    // TODO : publishing -> handle zoneID
    // Get.snackbar("Zone Error", "Zone ID is missing. Try restarting the app.",
    //     backgroundColor: Colors.red, colorText: Colors.white);
    // return false;
  }

  if (selectedDate == null) {
    Get.snackbar("Date Missing", "Please select a booking date.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }

  if (selectedTime == null) {
    Get.snackbar("Time Missing", "Please select a booking time.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }

  if (name.isEmpty) {
    Get.snackbar("Name Required", "Please enter your name.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  if (mobile.isEmpty) {
    Get.snackbar("Mobile Required", "Please enter your mobile number.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  if (email.isEmpty) {
    Get.snackbar("Email Required", "Please enter your email address.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  if (address.isEmpty) {
    Get.snackbar("Address Required", "Please enter your address.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  if (city == null || city.isEmpty) {
    city = "Default City";

    Get.snackbar("State Required", "Please enter your state.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  if (postalCode == null || postalCode.isEmpty) {
    Get.snackbar("Postal Code Required", "Please enter your postal code.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  if (country == null || country.isEmpty) {
    Get.snackbar("Country Required", "Please enter your country.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  if (street == null || street.isEmpty) {
    Get.snackbar("Street Required", "Please enter your street.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  if (addressType == null) {
    Get.snackbar("Address Type Required", "Please select address type.",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }
  print(
      "All fields: $name, $mobile, $email, $address, $city, $postalCode, $country, $street, $addressType");

  if (name.isEmpty ||
      mobile.isEmpty ||
      email.isEmpty ||
      address.isEmpty ||
      city == null ||
      city.isEmpty ||
      postalCode == null ||
      postalCode.isEmpty ||
      country == null ||
      country.isEmpty ||
      street == null ||
      street.isEmpty ||
      addressType == null) {
    Get.snackbar("Error", "Please fill in all required fields!",
        backgroundColor: Colors.red, colorText: Colors.white);
    return false;
  }

  return true;
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
