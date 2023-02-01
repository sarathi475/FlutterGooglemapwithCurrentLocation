import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LatLng _position = const LatLng(12.9715983, 77.5945617);
  final Map<String, Marker> _markers = {};
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    addMarker('my location', _position);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _position, zoom: 12),
        markers: _markers.values.toSet(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_on),
        onPressed: () {
          StreamSubscription<Position> positionStream =
              Geolocator.getPositionStream(locationSettings: locationSettings)
                  .listen((Position? position) {
            print("**********************\n\n\n");
            print(position == null
                ? 'Unknown'
                : '${position.latitude.toString()}, ${position.longitude.toString()}');
            if (position != null) {
              setState(() {
                _position = LatLng(position.latitude, position.longitude);
                _goToTheLake();
              });
            }
          });
        },
      ),
    );
  }

  Future<void> _goToTheLake() async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _position, zoom: 16)));
    addMarker('my location', _position);
  }

  addMarker(String id, LatLng location) async {
    var markerImage = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(60, 60)), 'assets/profile.png');
    var marker = Marker(
        markerId: MarkerId(id),
        position: location,
        icon: markerImage,
        infoWindow: InfoWindow(
            title: "my location", snippet: "this is your current location"));
    _markers[id] = marker;
  }
}
