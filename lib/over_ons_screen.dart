import 'package:flutter/material.dart';

class OverOnsScreen extends StatelessWidget {
  const OverOnsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF481d39),
        foregroundColor: Colors.white,
        title: const Text('Over ons'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logoHVV2.png',
                height: 120,
              ),
              const SizedBox(height: 30),
              const Text(
                'Over ons pagina\n\nContent komt hier',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF481d39),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}