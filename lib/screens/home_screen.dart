import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profiel_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeae2d5),
      body: Column(
        children: [
          // Rode header met logo en vraagteken
          Container(
            color: const Color(0xFFbd213f),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logoHVV2.png',
                        height: 50,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Help/info pagina openen
                    },
                    icon: const Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          // Content area
          Expanded(
            child: Stack(
              children: [
                // Hier komt later de kaart
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Je huidige locatie',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF481d39),
                          fontFamily: 'Offside',
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Klik op het uitroepteken om een',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF481d39),
                          fontFamily: 'Offside',
                        ),
                      ),
                      const Text(
                        'melding te maken!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF481d39),
                          fontFamily: 'Offside',
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating action button voor melding maken
                Positioned(
                  bottom: 100,
                  right: 24,
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: FloatingActionButton(
                      onPressed: () {
                        // TODO: Melding maken scherm openen
                      },
                      backgroundColor: const Color(0xFFf5a623),
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.push_pin,
                        color: Color(0xFF481d39),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rode footer met 4 iconen
          Container(
            color: const Color(0xFFbd213f),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home icoon
                    IconButton(
                      onPressed: () {
                        // Al op home
                      },
                      icon: const Icon(
                        Icons.home,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    // Wereld/globe icoon
                    IconButton(
                      onPressed: () {
                        // TODO: Navigeer naar wereld/ontdek pagina
                      },
                      icon: const Icon(
                        Icons.public,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    // Inbox/berichten icoon
                    IconButton(
                      onPressed: () {
                        // TODO: Navigeer naar berichten
                      },
                      icon: const Icon(
                        Icons.inbox,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    // Profiel icoon
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfielScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}