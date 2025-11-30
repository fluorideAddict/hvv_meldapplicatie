import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/firebase_options.dart';
import 'screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HartVoorVerkeerApp());
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
      debugShowCheckedModeBanner: false,
    );
  }
}