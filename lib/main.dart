import 'package:flutter/material.dart';
import 'start_screen.dart';

void main() {
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