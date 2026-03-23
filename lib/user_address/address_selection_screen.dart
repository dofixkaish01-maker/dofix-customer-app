import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import '../controllers/dashboard_controller.dart';

class AddressSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashBoardController>();

    //  ADD THIS
    if (controller.filteredAddresses.isEmpty)
      controller.filteredAddresses = controller.addressResponse.data;
    return Scaffold(
      appBar: AppBar(
          title: Text("Select Address"), backgroundColor: Color(0xFF207FA8)),
      body: GetBuilder<DashBoardController>(
        builder: (controller) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: TextEditingController(),
                    googleAPIKey: "AIzaSyBLI5I6o95GqluNuRh0YT3zRj5yqoix8zA",
                    inputDecoration: InputDecoration(
                        hintText: "Search location / Society",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none),
                    debounceTime: 600,
                    itemClick: (prediction) {
                      double lat = double.parse(prediction.lat ?? "0.0");
                      double lng = double.parse(prediction.lng ?? "0.0");

                      // 1. Update Lat Long
                      controller.updateLatLong(
                        lat.toString(),
                        lng.toString(),
                      );

                      //  2. Set Proper Address Text (No Custom Location)
                      controller.address =
                          prediction.structuredFormatting?.mainText ??
                              prediction.description ??
                              "";

                      controller.shortAddress.value =
                          prediction.structuredFormatting?.secondaryText ?? "";

                      //  3. Insert Into Recent Address List
                      controller.recentAddresses.insert(0, {
                        "title": prediction.structuredFormatting?.mainText ??
                            prediction.description,
                        "subtitle":
                            prediction.structuredFormatting?.secondaryText ??
                                "",
                        "lat": lat,
                        "lng": lng,
                      });

                      controller.update();

                      Get.back();
                    },
                  ),
                ),

                /// Current Location Option
                ListTile(
                  leading: Icon(Icons.my_location, color: Color(0xFF207FA8)),
                  title: Text("Use Current Location"),
                  onTap: () async {
                    await controller.requestLocationPermission();
                    // Get.back();
                    Navigator.of(context).pop();
                  },
                ),

                Divider(),

                /// Saved Address List
                Expanded(
                  child: ListView(
                    children: [
                      ///  Recent Addresses
                      if (controller.recentAddresses.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Recent Addresses",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        ...controller.recentAddresses.map((address) {
                          return ListTile(
                            leading: Icon(Icons.history, color: Colors.grey),
                            title: Text(address["title"] ?? ""),
                            subtitle: Text(address["subtitle"] ?? ""),
                            onTap: () {
                              controller.updateLatLong(
                                address["lat"].toString(),
                                address["lng"].toString(),
                              );

                              controller.address = address["title"];
                              controller.shortAddress.value =
                                  address["subtitle"] ?? "";

                              controller.update();
                              // Get.back();
                              Navigator.of(context).pop();
                            },
                          );
                        }).toList(),
                        Divider(),
                      ],

                      ///  Saved Addresses
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Saved Addresses",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),

                      ...controller.filteredAddresses.map((address) {
                        return ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(address.address ?? ""),
                          subtitle: Text(address.addressType ?? ""),
                          onTap: () {
                            controller.updateLatLong(
                              address.lat.toString(),
                              address.lon.toString(),
                            );

                            controller.address = address.address;
                            controller.shortAddress.value =
                                address.addressType ?? "";

                            controller.update();
                            // Get.back();
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
