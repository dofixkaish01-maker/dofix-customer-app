import 'dart:async';
import 'dart:convert';
import 'package:do_fix/widgets/common_loading.dart';
import 'package:do_fix/widgets/custom_snack_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../controllers/dashboard_controller.dart';
import '../../../../data/api/api.dart';
import '../../../../model/address_model.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/date_converter.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button_widget.dart';
import '../../PaymentScreen/payment_Screen.dart';
import '../../services/service_details_screen.dart';
// DashBoardController, DateConverter, formatTimeOfDay24Hour

class BookingSheet extends StatefulWidget {
  const BookingSheet({
    super.key,
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
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

  GoogleMapController? _mapController;
  LatLng _selectedLatLng = const LatLng(28.7041, 77.1025);
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  String addressType = "home";
  String servicePreference = "onsite";

  List<bool> _isVisibleList = List.filled(30, false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialLocation();
    });
  }

  void _triggerAnimations() async {
    for (int i = 0; i < _isVisibleList.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _isVisibleList[i] = true);
    }
  }

  Future<void> _setInitialLocation() async {
    debugPrint("Use Current Location inside");
    showLoading();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      hideLoading();
      showCustomSnackBar("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        hideLoading();
        showCustomSnackBar("Location services are disabled.");
        return;
      } else if (permission == LocationPermission.denied) {
        hideLoading();
        showCustomSnackBar("Location services are disabled.");
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
        addressController.text =
            "${place.street}, ${place.locality}, ${place.country}";
        Get.find<DashBoardController>().addressController.text =
            "${place.street}, ${place.locality}, ${place.country}";
        city = place.locality ?? "";
        state = place.administrativeArea ?? "";
        country = place.country ?? "";
        street = place.name ?? "";
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
                          ListTile(
                            onTap: () async {
                              debugPrint("Use Current Location");
                              await _setInitialLocation();
                              setState(() {
                                debugPrint("Use Current Location setstate");
                                selectedAddress = null;
                                // Navigator.of(context).pop();
                                Get.back();
                              });
                            },
                            leading: Icon(
                              selectedAddress != null
                                  ? Icons.location_searching
                                  : Icons.my_location,
                              color: Colors.blue,
                            ),
                            title: const Text("Use Current Location"),
                          ),
                          const Divider(),
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              itemCount: addressList.length,
                              itemBuilder: (context, index) {
                                final address = addressList[index];
                                return RadioListTile<AddressData>(
                                  value: address,
                                  groupValue: selectedAddress,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAddress = value;
                                    });
                                    onSelectAddress(value!);
                                    // Get.back();
                                  },
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          address.address,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.grey),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          showAddNewAddressDialog(context);
                                        },
                                      ),
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
                    Text("Add Address",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                                          mapController.text =
                                              "${place.street}, ${place.locality}, ${place.country}";
                                          city = place.locality ?? "";
                                          state =
                                              place.administrativeArea ?? "";
                                          country = place.country ?? "";
                                          street = place.name ?? "";
                                          postalCode = place.postalCode ?? "";

                                          streetController.text =
                                              place.name ?? "";
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
                        controller: streetController, hintText: "Street")),
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
                      // Basic validation
                      if (nameController.text.trim().isEmpty) {
                        showCustomSnackBar("Please enter contact person name");
                        return;
                      }

                      if (mobileController.text.trim().isEmpty) {
                        showCustomSnackBar("Please enter contact number");
                        return;
                      }

                      // if (addressController.text.trim().isEmpty) {
                      //   showCustomSnackBar("Please enter address");
                      //   return;
                      // }

                      if (_selectedLatLng == null) {
                        showCustomSnackBar("Please select a location on map");
                        return;
                      }

                      if (city.trim().isEmpty) {
                        showCustomSnackBar("Please enter city");
                        return;
                      }

                      if (street.trim().isEmpty) {
                        showCustomSnackBar("Please enter street");
                        return;
                      }

                      if (postalCode.trim().isEmpty) {
                        showCustomSnackBar("Please enter zip/postal code");
                        return;
                      }

                      if (country.trim().isEmpty) {
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

                      // If all validations pass
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
                            "${houseController.text.trim()},${floorController.text.trim()},${addressController.text.trim()}",
                        createdAt: DateTime.now().toString(),
                        updatedAt: DateTime.now().toString(),
                        addressType: addressType,
                        contactPersonName: nameController.text.trim(),
                        contactPersonNumber: mobileController.text.trim(),
                        addressLabel: addressType,
                        zoneId:
                            Get.find<DashBoardController>().zoneIdForBooking,
                        isGuest: false,
                        house: houseController.text.trim(),
                        floor: floorController.text.trim(),
                      );

                      await Get.find<DashBoardController>()
                          .addAddress(newAddress)
                          .then((value) async {
                        await Future.delayed(Duration(seconds: 1));
                        await Get.find<DashBoardController>().getAddressLists();

                        if (Get.find<DashBoardController>()
                            .addressResponse
                            .data
                            .isNotEmpty) {
                          showAddressChoiceDialog(
                              context,
                              Get.find<DashBoardController>()
                                  .addressResponse
                                  .data, (address) {
                            Get.find<DashBoardController>()
                                .selectedAddressLists
                                .clear();
                            Get.find<DashBoardController>()
                                .selectedAddressLists
                                .add(address);
                            setState(() {
                              _selectedLatLng = LatLng(
                                address.lat,
                                address.lon,
                              );
                              addressController.text = address.address;
                              Get.find<DashBoardController>()
                                  .addressController
                                  .text = address.address;
                              city = address.city ?? "";
                              houseController.text = address.house ?? "";
                              floorController.text = address.floor ?? "";
                              country = address.country ?? "";
                              street = address.street ?? "";
                              postalCode = address.zipCode ?? "";
                              Get.find<DashBoardController>().update();
                            });
                            // showAddNewAddressDialog(context);
                            Get.back();
                            Get.back();
                            Get.to(BookingSheet());
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
                                city = address.city ?? "";
                                houseController.text = address.house ?? "";
                                floorController.text = address.floor ?? "";
                                country = address.country ?? "";
                                street = address.street ?? "";
                                postalCode = address.zipCode ?? "";
                                Get.find<DashBoardController>().update();
                              });
                              showAddNewAddressDialog(context);
                            });
                          });
                        }
                      });

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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
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
                        child: Icon(Icons.arrow_back,
                            size: 30, color: Theme.of(context).primaryColor),
                      ),
                      const Spacer(),
                      const Text("Book Service",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                buildAnimatedItem(
                  index: 1,
                  child: Row(
                    children: const [
                      Text("Personal Information",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 2,
                    child: CustomTextField(
                      controller: nameController,
                      hintText: "Name",
                      inputType: TextInputType.name,
                    )),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 3,
                    child: CustomTextField(
                      controller: mobileController,
                      hintText: "Mobile Number",
                      inputType: TextInputType.number,
                      isPhone: true,
                      isNumber: true,
                    )),
                const SizedBox(height: 15),
                buildAnimatedItem(
                  index: 4,
                  child: CustomTextField(
                    controller: emailController,
                    hintText: "Email",
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(height: 15),
                buildAnimatedItem(
                  index: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Service Preference",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Radio<String>(
                              value: "onsite",
                              groupValue: servicePreference,
                              onChanged: (value) =>
                                  setState(() => servicePreference = value!)),
                          const Text("On-site Repair"),
                          Radio<String>(
                              value: "serviceman_pickup ",
                              groupValue: servicePreference,
                              onChanged: (value) =>
                                  setState(() => servicePreference = value!)),
                          const Text("Technician Pickup"),
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
                      Text("Select Date and Time",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                buildAnimatedItem(
                  index: 7,
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        height: 50,
                        width: Get.size.width,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 3,
                                blurRadius: 4,
                                offset: Offset(0, 3),
                              ),
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    "Select Date: ${selectedDate.toLocal().toString().split(' ')[0]}")),
                            Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                buildAnimatedItem(
                  index: 8,
                  child: GestureDetector(
                    onTap: () async {
                      TimeOfDay now = TimeOfDay.now();
                      DateTime nowDateTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        now.hour,
                        now.minute,
                      );
                      DateTime minDateTime =
                          nowDateTime.add(Duration(hours: 2, minutes: 10));
                      TimeOfDay minTime = TimeOfDay(
                          hour: minDateTime.hour, minute: minDateTime.minute);

                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: minTime,
                      );

                      if (picked != null) {
                        // Convert to DateTime for comparison
                        DateTime full = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          picked.hour,
                          picked.minute,
                        );

                        DateTime nowTime =
                            DateTime.now().add(Duration(hours: 2));
                        DateTime earliest = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          9,
                          0,
                        );
                        DateTime latest = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          20,
                          0,
                        );

                        if (full.isBefore(nowTime)) {
                          showCustomSnackBar(
                              "Please select a time at least 2 hours from now");
                          return;
                        }

                        if (full.isBefore(earliest) || full.isAfter(latest)) {
                          showCustomSnackBar(
                              "Please select a time between 9 AM and 8 PM");
                          return;
                        }

                        setState(() => selectedTime = picked);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        height: 50,
                        width: Get.size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 4,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedTime != null
                                    ? "Select Time: ${selectedTime!.format(context)}"
                                    : "Select Time",
                              ),
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                buildAnimatedItem(
                  index: 10,
                  child: Row(
                    children: [
                      Text("Address & LandMark",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                buildAnimatedItem(
                  index: 17,
                  child: CustomTextField(
                    controller:
                        Get.find<DashBoardController>().addressController,
                    hintText: "Address",
                    focusNode: addressFocus,
                    onTap: () {
                      // Handle address field tap
                      // You can implement your logic here
                    },
                    suffixIcon: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
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
                            city = address.city ?? "";
                            houseController.text = address.house ?? "";
                            floorController.text = address.floor ?? "";
                            country = address.country ?? "";
                            street = address.street ?? "";
                            postalCode = address.zipCode ?? "";
                            Get.find<DashBoardController>().update();
                          });
                          // showAddNewAddressDialog(context);
                          Get.back();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                buildAnimatedItem(
                    index: 18,
                    child: CustomTextField(
                        controller: messageController, hintText: "Message")),
                const SizedBox(height: 20),
                buildAnimatedItem(
                  index: 19,
                  child: CustomButtonWidget(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final mobile = mobileController.text.trim();
                      final email = emailController.text.trim();
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
                        address: address,
                        selectedLatLng: _selectedLatLng,
                        zoneId: dashController.zoneIdForBooking,
                        selectedDate: selectedDate,
                        selectedTime: selectedTime,
                        city: city,
                        postalCode: postalCode,
                        country: country,
                        street: street,
                        addressType: addressType,
                        selectedVariations: dashController.selectedVariations,
                      )) return;

                      // Show Bottom Sheet for Payment Method Selection
                      final selectedPaymentMethod =
                          await showModalBottomSheet<String>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.money),
                              title: Text("Cash on Delivery"),
                              onTap: () {
                                dashController.postOrder({
                                  "name": name,
                                  "mobile_number": mobile,
                                  "address_label": addressType.toString(),
                                  "email": email,
                                  "address": address,
                                  "lat": _selectedLatLng.latitude,
                                  "lng": _selectedLatLng.longitude,
                                  "zone_id": dashController.zoneIdForBooking,
                                  "message": message,
                                  "date": DateConverter.dateTimeForCoupon(
                                          selectedDate)
                                      .toString(),
                                  "time": formatTimeOfDay24Hour(
                                          selectedTime ?? TimeOfDay.now())
                                      .toString(),
                                  "payment_method": "cash_after_service",
                                  "city": city,
                                  "zip_code": postalCode,
                                  "country": country,
                                  "street": street,
                                  "service_preference": servicePreference
                                }, dashController.selectedVariations,
                                    showLoader: false);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.payment),
                              title: Text("Online Payment"),
                              onTap: () {
                                makeDigitalPayment(
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
                                    "date": DateConverter.dateTimeForCoupon(
                                            selectedDate)
                                        .toString(),
                                    "time": formatTimeOfDay24Hour(
                                            selectedTime ?? TimeOfDay.now())
                                        .toString(),
                                    "payment_method": "razor_pay",
                                    "city": city,
                                    "zip_code": postalCode,
                                    "country": country,
                                    "street": street,
                                    "service_preference": servicePreference
                                  },
                                  onPressed: () {
                                    debugPrint("OnPressed Called====>");
                                    dashController.postOrder({
                                      "name": name,
                                      "mobile_number": mobile,
                                      "address_label": addressType.toString(),
                                      "email": email,
                                      "address": address,
                                      "lat": _selectedLatLng.latitude,
                                      "lng": _selectedLatLng.longitude,
                                      "zone_id":
                                          dashController.zoneIdForBooking,
                                      "message": message,
                                      // can be empty or null
                                      "date": DateConverter.dateTimeForCoupon(
                                              selectedDate)
                                          .toString(),
                                      "time": formatTimeOfDay24Hour(
                                              selectedTime ?? TimeOfDay.now())
                                          .toString(),
                                      "payment_method": "razor_pay",
                                      "city": city,
                                      "zip_code": postalCode,
                                      "country": country,
                                      "street": street,
                                      "service_preference": servicePreference
                                    }, dashController.selectedVariations,
                                        showLoader: true);
                                  },
                                );
                              },
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      );
                    },
                    buttonText: 'Book Now', width:  MediaQuery.of(context).size.width - 40,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),          ),
        ),
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
    // TODO : publishing -> handle city
    // Get.snackbar("City Required", "Please enter your city.",
    //     backgroundColor: Colors.red, colorText: Colors.white);
    // return false;
  }
  if (postalCode == null || postalCode.isEmpty) {
    postalCode = "000000";
    // TODO : publishing -> handle postal code
    // Get.snackbar("Postal Code Required", "Please enter your postal code.",
    //     backgroundColor: Colors.red, colorText: Colors.white);
    // return false;
  }
  if (country == null || country.isEmpty) {
    country = "Default Country";
    // TODO : publishing -> handle country
    // Get.snackbar("Country Required", "Please enter your country.",
    //     backgroundColor: Colors.red, colorText: Colors.white);
    // return false;
  }
  if (street == null || street.isEmpty) {
    street = "Default Street";
    // TODO : publishing -> handle street
    // Get.snackbar("Street Required", "Please enter your street.",
    //     backgroundColor: Colors.red, colorText: Colors.white);
    // return false;
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
    required Map<String, dynamic> data}) async {
  String url = '';
  await Get.find<DashBoardController>().getUserInfo(false);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  ApiClient apiClient = ApiClient(
      appBaseUrl: AppConstants.baseUrl, sharedPreferences: preferences);
  String zoneId = apiClient.mainHeaders['zone_id'] ??
      "e8554d44-dcf2-47c7-8cf9-400d05a1340f";
  String userId = Get.find<DashBoardController>().userModel.id;
  int isPartial = 0;
  String platform = "app";
  Map<String, dynamic> address = {
    "lat": "${data["lat"]}",
    "lon": "${data["lng"]}",
    "address_label": "${data["address_label"]}",
    "address": "${data["address"]}",
    "contact_person_name": "${data["name"]}",
    "contact_person_number": "+91${data["mobile_number"]}",
  };
  String encodedAddress = base64Encode(utf8.encode(jsonEncode(address)));
  final combined = '${data["date"]} ${data["time"]}';
  final dateTime = DateTime.parse(combined);

// Format as 'yyyy-MM-dd HH:mm:ss'
  final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  debugPrint("encodedError $encodedAddress");
  url =
      '${AppConstants.baseUrl}payment?payment_method=razor_pay&access_token=${base64Url.encode(utf8.encode(userId))}&zone_id=$zoneId'
      '&service_schedule=${formatted}&service_address_id=null&callback=https://panel.dofix.in&service_address=$encodedAddress&new_user_info=null&is_partial=$isPartial&payment_platform=$platform';

  debugPrint("url_with_digital_payment:$url");

  await Get.to(() => PaymentScreen(
        url: url,
        fromPage: "switch-payment-method",
        onPressed: onPressed,
        data: data,
      ));
}
