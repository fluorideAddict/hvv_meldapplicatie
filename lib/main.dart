import 'package:flutter/material.dart';
import 'package:hvv_meldapplicatie/screens/map/home_screen.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'start_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //String ACCESS_TOKEN = const String.fromEnvironment("pk.eyJ1Ijoid2Fnb24tb2YtZG9qaW1hIiwiYSI6ImNtaHZwZ2lrbTA5M2Uya3IyNzlsaHg4YnEifQ.V2UQiWmY-7oneGChjf9Akg");
  MapboxOptions.setAccessToken("pk.eyJ1Ijoid2Fnb24tb2YtZG9qaW1hIiwiYSI6ImNtaHZwZ2lrbTA5M2Uya3IyNzlsaHg4YnEifQ.V2UQiWmY-7oneGChjf9Akg");

  CameraOptions camera = CameraOptions(
      center: Point(coordinates: Position(-98.0, 39.5)),
      zoom: 2,
      bearing: 0,
      pitch: 0);

  //runApp(const HartVoorVerkeerApp());
  runApp(MaterialApp(home: MapWidget(
    cameraOptions: camera,
  )));
}

class HartVoorVerkeerApp extends StatelessWidget {
  const HartVoorVerkeerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hart voor Verkeer',
      theme: ThemeData(
        primaryColor: const Color(0xFF481d39),
        scaffoldBackgroundColor: const Color(0xFFEAE2D5),
      ),
      home: const StartScreen(),
      //home: MapWidget(cameraOptions: camera,
      // ),
      debugShowCheckedModeBanner: false,
    );
  }
}