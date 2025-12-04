import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

CameraOptions camera = CameraOptions(
    center: Point(
        coordinates: Position(
          5.2333,
          52.0906
        )
    ),
    zoom: 12,
    bearing: 0,
    pitch: 0
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF481d39),
        foregroundColor: Colors.white,
        title: const Text('placeholder'),
      ),
      body: MapWidget(
        cameraOptions: camera,
        // styleString: MapboxStyles.MAPBOX_STREETS,
        // initialCameraPosition: CameraPosition(
        //   target: _initialPosition,
        //   zoom: 12,
        // ),
        // accessToken: "YOUR_MAPBOX_ACCESS_TOKEN_HERE",
        // onMapCreated: _onMapCreated,
        // myLocationEnabled: true,
        // myLocationTrackingMode: MyLocationTrackingMode.Tracking,
        // rotateGesturesEnabled: true,
        // tiltGesturesEnabled: true,
        // compassEnabled: true,
        // zoomGesturesEnabled: true,
      ),

      // BOTTOM NAV BAR
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onNavTapped,
      //   items: const [
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.map), label: "Map"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.place), label: "Places"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.settings), label: "Settings"),
      //  ],
      //),
    );
  }
}