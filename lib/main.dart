import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hvv_meldapplicatie/screens/map/home_screen.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'start_screen.dart';
//import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

void main() async{
  //String ACCESS_TOKEN = const String.fromEnvironment("pk.eyJ1Ijoid2Fnb24tb2YtZG9qaW1hIiwiYSI6ImNtaHZwZ2lrbTA5M2Uya3IyNzlsaHg4YnEifQ.V2UQiWmY-7oneGChjf9Akg");
  //sMapboxOptions.setAccessToken("pk.eyJ1Ijoid2Fnb24tb2YtZG9qaW1hIiwiYSI6ImNtaHZwZ2lrbTA5M2Uya3IyNzlsaHg4YnEifQ.V2UQiWmY-7oneGChjf9Akg");
  await setup();
  runApp(const HartVoorVerkeerApp());
  //runApp(MaterialApp(home: MapWidget(
  //  cameraOptions: camera,
  //)));
}

Future<void> setup() async {
  await dotenv.load(fileName: ".env",);
  MapboxOptions.setAccessToken(dotenv.env["MAPBOX_ACCESS_TOKEN"]!);
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
      //home: const StartScreen(),

      // home: MapWidget(
      //   cameraOptions: camera,
      // ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}