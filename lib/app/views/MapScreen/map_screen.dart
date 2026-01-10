import 'package:do_fix/app/widgets/custom_button_widget.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  String _address = "Search location";
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    if (_currentPosition != null) {
      _controller!.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _address = "${place.street}, ${place.locality}, ${place.country}";
        _searchController.text = _address;
        // Get.find<DashBoardController>().addressController.text = _address;
        // Get.find<DashBoardController>().lat = position.latitude.toString();
        // Get.find<DashBoardController>().long = position.longitude.toString();
        // Get.find<DashBoardController>().updateValues(_address, position.latitude.toString(), position.longitude.toString());
        Get.find<DashBoardController>().getZoneIdForBooking();
      });
    } catch (e) {
      print(e);
    }
  }

  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location")),
      body: Stack(
        children: [
          if (_currentPosition != null)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  CameraPosition(target: _currentPosition!, zoom: 18),
              onCameraMove: (position) {
                setState(() => _currentPosition = position.target);
              },
              onCameraIdle: () => _getAddressFromLatLng(_currentPosition!),
              markers: {
                Marker(
                  markerId: MarkerId("current"),
                  position: _currentPosition!,
                  draggable: true,
                  onDragEnd: (newPosition) {
                    _getAddressFromLatLng(newPosition);
                    setState(() => _currentPosition = newPosition);
                  },
                ),
              },
            ),
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: GooglePlaceAutoCompleteTextField(
              focusNode: focusNode,
              textEditingController: _searchController,
              googleAPIKey: "AIzaSyBLI5I6o95GqluNuRh0YT3zRj5yqoix8zA",
              inputDecoration: InputDecoration(
                hintText: "Search location",
                fillColor: Colors.white,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              debounceTime: 600,
              itemClick: (prediction) {
                double lat = double.parse(prediction.lat ?? "0.0");
                double lng = double.parse(prediction.lng ?? "0.0");
                setState(() {
                  _currentPosition = LatLng(lat, lng);
                });
                _controller
                    ?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
              },
              getPlaceDetailWithLatLng: (prediction) async {
                double lat = double.parse(prediction.lat ?? "0.0");
                double lng = double.parse(prediction.lng ?? "0.0");
                setState(() {
                  _currentPosition = LatLng(lat, lng);
                });
                _controller
                    ?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Container(
              width: MediaQuery.of(context).size.width - 20,
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                children: [
                  Text("Address: $_address", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  CustomButtonWidget(
                    width: MediaQuery.of(context).size.width - 40,
                    onPressed: () {
                      Get.back();
                    },
                    buttonText: 'Confirm',
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
