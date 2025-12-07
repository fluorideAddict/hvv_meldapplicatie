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
}