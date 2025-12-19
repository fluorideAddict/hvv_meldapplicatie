import 'package:flutter/material.dart';
import 'screens/account_aanmaken_screen.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo klein bovenaan
              Center(
                child: Image.asset(
                  'assets/images/logoHVV2.png',
                  height: 60,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Privacybeleid',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF481d39),
                  fontFamily: 'Oswald',
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
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
              const SizedBox(height: 20),
              // Ik ga akkoord button
              SizedBox(
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}