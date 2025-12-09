import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
//import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as gl;
//import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  mb.MapboxMap? mapboxMapController;

  StreamSubscription? userPositionStream;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }
  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF481d39),
        foregroundColor: Colors.white,
        title: const Text('placeholder'),
      ),
      body: mb.MapWidget(
        //cameraOptions: camera,
        onMapCreated: _onMapCreated,
      ),

      //BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  void _onMapCreated(mb.MapboxMap controller) {
    setState(() {
      mapboxMapController = controller;
    });
    mapboxMapController?.location.updateSettings(
      mb.LocationComponentSettings(
        enabled: true,
      ),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
        locationSettings: locationSettings).listen(
        (
        gl.Position? position,
        ) {
          if (position != null && mapboxMapController != null) {
            mapboxMapController?.setCamera(
              mb.CameraOptions(
                  center: mb.Point(
                      coordinates: mb.Position(
                        position.longitude,
                        position.latitude,
                      )
                  ),
                  zoom: 15,
                  bearing: 0,
                  pitch: 0
              )
            );
          }
        },
    );
  }
}