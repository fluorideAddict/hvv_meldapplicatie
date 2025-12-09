import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'account_aanmaken_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _textReveal;
  late Animation<double> _textOpacity;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Header (terug knop + logo) animatie (0.0 - 0.5)
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

    // Title animatie (0.1 - 0.6)
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

    // Text "reveal" animatie - sneller uitrollen (0.15 - 0.7)
    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Text opacity - sneller fade (0.15 - 0.6)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
      ),
    );

    // Button animatie (0.2 - 0.75)
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              // Terug knop en logo met animatie
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
                    'Privacybeleid',
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
              const SizedBox(height: 10),
              // Text met snellere "reveal" animatie EN scrollable
              Expanded(
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: SingleChildScrollView(
                    child: const Text(
                      'Wij hechten veel waarde aan jouw privacy. De Meldsysteem-app verzamelt alleen gegevens die nodig zijn om verkeersmeldingen mogelijk te maken en de veiligheid in jouw omgeving te verbeteren. Wanneer je een melding maakt, worden locatiegegevens, categorie en beschrijving opgeslagen. De locatie wordt uitsluitend gebruikt om de melding correct op de kaart weer te geven. Je kunt ervoor kiezen om je locatie handmatig in te voeren als je GPS-toegang niet wilt delen.\n\n'
                          'Gebruikers kunnen anoniem deelnemen door een willekeurige gebruikersnaam te gebruiken. Persoonlijke informatie zoals je echte naam, adres of contactgegevens is niet vereist. Alle gegevens worden beveiligd opgeslagen en alleen gedeeld met bevoegde beleidsmakers die verantwoordelijk zijn voor verkeersveiligheid. Foto\'s en teksten in meldingen worden uitsluitend gebruikt voor analyse en visualisatie binnen de app.\n\n'
                          'Je hebt altijd het recht om je account en bijbehorende gegevens te verwijderen. De app voldoet aan de geldende privacywetgeving (AVG). Door de app te gebruiken ga je akkoord met dit beleid en met het gebruik van jouw gegevens voor de hierboven beschreven doeleinden.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF481d39),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Button met animatie
              FadeTransition(
                opacity: _buttonOpacity,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountAanmakenScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF481d39),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Ik ga akkoord',
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
    );
  }
}