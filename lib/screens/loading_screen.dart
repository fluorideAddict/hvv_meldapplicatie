import 'package:flutter/material.dart';
import 'account_gemaakt_screen.dart';
import '../services/firebase_service.dart';

class LoadingScreen extends StatefulWidget {
  final String username;
  final int avatar;
  final String ageCategory;

  const LoadingScreen({
    Key? key,
    required this.username,
    required this.avatar,
    required this.ageCategory,
  }) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _statusMessage = 'Account wordt aangemaakt...';

  @override
  void initState() {
    super.initState();
    _createAccount();
  }

  Future<void> _createAccount() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _statusMessage = 'Gebruikersnaam wordt gecontroleerd...';
      });

      final result = await _firebaseService.createAccount(
        username: widget.username,
        avatar: widget.avatar,
        ageCategory: widget.ageCategory,
      );

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _statusMessage = 'Account succesvol aangemaakt!';
        });

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AccountGemaaktScreen(
                username: widget.username,
                avatar: widget.avatar,
              ),
            ),
          );
        }
      } else {
        final errorMessage = result['error'] ?? 'Er is een fout opgetreden';
        
        if (mounted) {
          _showErrorDialog(errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Er is een onverwachte fout opgetreden.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Fout',
          style: TextStyle(
            color: Color(0xFF481d39),
            fontFamily: 'Oswald',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF481d39),
          ),
        ),
        backgroundColor: const Color(0xFFeae2d5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Probeer opnieuw',
              style: TextStyle(
                color: Color(0xFF481d39),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo bovenaan gecentreerd
              Center(
                child: Image.asset(
                  'assets/images/logoHVV2.png',
                  height: 60,
                ),
              ),
              const SizedBox(height: 200),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF481d39)),
                strokeWidth: 5,
              ),
              const SizedBox(height: 40),
              // Loading tekst
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF481d39),
                  fontFamily: 'Oswald',
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}