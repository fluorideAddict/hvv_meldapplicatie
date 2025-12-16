import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/start_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setup();
  runApp(const HartVoorVerkeerApp());
}

Future<void> setup() async {
  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env["MAPBOX_ACCESS_TOKEN"]!);
}

class HartVoorVerkeerApp extends StatelessWidget {
  const HartVoorVerkeerApp({Key? key}) : super(key: key);

  determineNextPage() {
    //error handling in case firebase service is not reachable? what happens if the user has no internet connection?
    if(FirebaseService().isUserLoggedIn()){
      return HomeScreen();
    }
    return StartScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hart voor Verkeer',
      theme: ThemeData(
        primaryColor: const Color(0xFF481d39),
        scaffoldBackgroundColor: const Color(0xFFEAE2D5),
      ),
      home: determineNextPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}