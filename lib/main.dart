import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/start_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hart voor Verkeer',
      theme: ThemeData(
        primaryColor: const Color(0xFF481d39),
        scaffoldBackgroundColor: const Color(0xFFEAE2D5),
      ),
      home: const AuthWrapper(), // ⭐ Check eerst of user ingelogd is
      debugShowCheckedModeBanner: false,
    );
  }
}

// ⭐ NIEUWE WRAPPER - Checkt of gebruiker al ingelogd is
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Wacht tot we weten of er een user is
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFeae2d5),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF481d39),
              ),
            ),
          );
        }

        // Als er een user is, ga naar HomeScreen
        if (snapshot.hasData) {
          print('✅ User is already logged in: ${snapshot.data?.uid}');
          return const HomeScreen();
        }

        // Anders, ga naar StartScreen
        print('❌ No user logged in, showing StartScreen');
        return const StartScreen();
      },
    );
  }
}