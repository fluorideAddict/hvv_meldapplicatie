import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'loading_screen.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountAanmakenScreen extends StatefulWidget {
  const AccountAanmakenScreen({Key? key}) : super(key: key);

  @override
  State<AccountAanmakenScreen> createState() => _AccountAanmakenScreenState();
}

class _AccountAanmakenScreenState extends State<AccountAanmakenScreen> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  String? selectedAge;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _iconOpacity;
  late Animation<Offset> _iconSlide;
  late Animation<double> _usernameOpacity;
  late Animation<Offset> _usernameSlide;
  late Animation<double> _ageOpacity;
  late Animation<Offset> _ageSlide;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  final List<String> adjectives = [
    'Snelle', 'Vrolijke', 'Slimme', 'Dappere', 'Koele',
    'Sterke', 'Wilde', 'Rustige', 'Gelukkige', 'Stoere',
    'Vlotte', 'Handige', 'Leuke', 'Grappige', 'Slimme',
    'Brave', 'Frisse', 'Heldere', 'Vloeiende', 'Soepele',
    'Snedige', 'Pittige', 'Energieke', 'Alerte', 'Wakere',
    'Slimme', 'Handige', 'Kundige', 'Ervaren', 'Bedreven',
    'Attente', 'Oplettende', 'Scherpe', 'Heldere', 'Heldere',
    'Betrouwbare', 'Veilige', 'Zekere', 'Stabiele', 'Vaste',
    'Trendy', 'Moderne', 'Hippe', 'Coole', 'Gave',
    'Vroege', 'Punctuele', 'Tijdige', 'Snelle', 'Vlugge',
    'Groene', 'Duurzame', 'Zuinige', 'Milieuvriendelijke', 'Schone'
  ];

  final List<String> nouns = [
    'Fietser', 'Rijder', 'Voetganger', 'Automobilist', 'Wandelaar',
    'Chauffeur', 'Bestuurder', 'Reiziger', 'Pendler', 'Weggebruiker',
    'Scholier', 'Student', 'Werker', 'Bezoeker', 'Bewoner',
    'Wielrenner', 'Mountainbiker', 'Scooteraar', 'Bromfietser', 'Motorrijder',
    'Tram', 'Buspassagier', 'Metrogebruiker', 'Treinreiziger', 'Carpoller',
    'Skater', 'Stepgebruiker', 'Elektrischefiets', 'Bakfiets', 'Stadsfietser',
    'Forens', 'Toerist', 'Dagjesmensch', 'Uitstapper', 'Passant',
    'Verkennaar', 'Ontdekkaar', 'Avonturier', 'Routeplanner', 'Navigator',
    'Stadsbewoner', 'Dorpeling', 'Wijkbewoner', 'Buurtgenoot', 'Streekgenoot',
    'Snelheidsduivel', 'Rustzoekar', 'Veiligheidsfreak', 'Meldmelder', 'Rapporteur',
    'Verkeersengel', 'Wegheld', 'Straatkenner', 'Routemeester', 'Verkeerskenner'
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Header (0.0 - 0.5)
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Title (0.1 - 0.6)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Icon (0.15 - 0.65)
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _iconSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // Username field (0.2 - 0.7)
    _usernameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _usernameSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Age dropdown (0.25 - 0.75)
    _ageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _ageSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Button (0.3 - 0.8)
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void generateRandomUsername() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ⭐ CHECK OF USER IS INGELOGD, ZO NIET -> LOGIN
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('🔐 User not logged in, signing in anonymously...');
        await FirebaseAuth.instance.signInAnonymously();
        print('✅ Signed in anonymously');
      }

      final random = Random();
      int attempts = 0;
      const maxAttempts = 10;

      while (attempts < maxAttempts) {
        final adjective = adjectives[random.nextInt(adjectives.length)];
        final noun = nouns[random.nextInt(nouns.length)];
        final number = random.nextInt(9999) + 1;

        final username = '$adjective$noun$number';

        try {
          // ❌ TIMEOUT VERWIJDERD - Direct checken
          final isAvailable = await _firebaseService.isUsernameAvailable(username);

          if (isAvailable) {
            setState(() {
              usernameController.text = username;
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          print('Error checking username $username: $e');
        }

        attempts++;
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kon geen beschikbare gebruikersnaam vinden. Probeer het later opnieuw of voer handmatig een gebruikersnaam in.'),
            backgroundColor: Color(0xFF945a7f),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Unexpected error in generateRandomUsername: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Er is een fout opgetreden. Probeer het opnieuw.'),
            backgroundColor: Color(0xFF945a7f),
          ),
        );
      }
    }
  }

  Future<void> _createAccount() async {
    if (usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voer een gebruikersnaam in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecteer je leeftijdscategorie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          username: usernameController.text.trim(),
          avatar: 1, // Default avatar waarde (niet meer gebruikt maar nog nodig voor LoadingScreen)
          ageCategory: selectedAge!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header met animatie
                FadeTransition(
                  opacity: _headerOpacity,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: SvgPicture.asset(
                            'assets/icons/arrow-prev-svgrepo-com.svg',
                            width: 35,
                            height: 35,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF481d39),
                              BlendMode.srcIn,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              'assets/images/logoHVV2.png',
                              height: 60,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Title met animatie
                FadeTransition(
                  opacity: _titleOpacity,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: const Text(
                      'Account aanmaken',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF481d39),
                        fontFamily: 'Oswald',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // User icon met animatie
                FadeTransition(
                  opacity: _iconOpacity,
                  child: SlideTransition(
                    position: _iconSlide,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF481d39),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF481d39),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: Color(0xFFeae2d5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Username field met animatie
                FadeTransition(
                  opacity: _usernameOpacity,
                  child: SlideTransition(
                    position: _usernameSlide,
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Gebruikersnaam',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF481d39),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Offside',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: TextField(
                            controller: usernameController,
                            enabled: !_isLoading,
                            style: const TextStyle(
                              color: Color(0xFF481d39),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFeae2d5),
                              hintText: 'Voer je gebruikersnaam in',
                              hintStyle: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 15,
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF481d39),
                                      ),
                                    ),
                                  ),
                                )
                                    : IconButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    generateRandomUsername();
                                  },
                                  icon: const Icon(
                                    Icons.casino,
                                    color: Color(0xFF481d39),
                                    size: 24,
                                  ),
                                  tooltip: 'Genereer random gebruikersnaam',
                                  splashRadius: 20,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: Color(0xFF481d39),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: Color(0xFF481d39),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: Color(0xFF481d39),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Age dropdown met animatie
                FadeTransition(
                  opacity: _ageOpacity,
                  child: SlideTransition(
                    position: _ageSlide,
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Leeftijdscategorie',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF481d39),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Offside',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFeae2d5),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFF481d39),
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedAge,
                              hint: const Text(
                                'Selecteer je leeftijdscategorie',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 15,
                                ),
                              ),
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF481d39),
                                size: 28,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF481d39),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              dropdownColor: const Color(0xFFeae2d5),
                              borderRadius: BorderRadius.circular(16),
                              items: const [
                                DropdownMenuItem(
                                  value: 'younger-16',
                                  child: Text('Jonger dan 16'),
                                ),
                                DropdownMenuItem(
                                  value: '16-24',
                                  child: Text('16 - 24 jaar'),
                                ),
                                DropdownMenuItem(
                                  value: '25-34',
                                  child: Text('25 - 34 jaar'),
                                ),
                                DropdownMenuItem(
                                  value: '35-44',
                                  child: Text('35 - 44 jaar'),
                                ),
                                DropdownMenuItem(
                                  value: '45-54',
                                  child: Text('45 - 54 jaar'),
                                ),
                                DropdownMenuItem(
                                  value: '55-64',
                                  child: Text('55 - 64 jaar'),
                                ),
                                DropdownMenuItem(
                                  value: '65-plus',
                                  child: Text('65+'),
                                ),
                              ],
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                setState(() {
                                  selectedAge = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Button met animatie
                FadeTransition(
                  opacity: _buttonOpacity,
                  child: SlideTransition(
                    position: _buttonSlide,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF481d39),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF945a7f),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : const Text(
                          'Verder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}