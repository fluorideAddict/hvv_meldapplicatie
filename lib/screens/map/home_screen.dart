import 'package:flutter/material.dart';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
        ),
      ),
    );
  }
}