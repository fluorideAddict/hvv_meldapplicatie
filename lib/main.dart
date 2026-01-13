import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/start_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ LAAD DE .ENV FILE
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hart voor Verkeer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFbd213f)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFeae2d5), // ⭐ DEFAULT BACKGROUND COLOR
      ),
      home: FutureBuilder<Widget>(
        future: determineNextPage(),
        builder: (context, snapshot) {
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
          return snapshot.data ?? const StartScreen();
        },
      ),
    );
  }

  Future<Widget> determineNextPage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return const StartScreen();
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        return const StartScreen();
      }

      return const HomeScreen();

    } catch (e) {
      return const StartScreen();
    }
  }
}