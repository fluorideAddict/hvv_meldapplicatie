import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OverOnsScreen extends StatelessWidget {
  const OverOnsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Terug knop en logo
              Row(
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
              const SizedBox(height: 30),
              // Title
              const Text(
                'Over ons',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF481d39),
                  fontFamily: 'Oswald',
                ),
              ),
              const SizedBox(height: 10),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visie
                      const Text(
                        'Onze visie',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF481d39),
                          fontFamily: 'Oswald',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '"Een betere wereld door duurzame en veilige mobiliteit."',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF481d39),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // De mens centraal
                      const Text(
                        'De mens centraal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF481d39),
                          fontFamily: 'Oswald',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mensen vormen samen het verkeer. Verkeer is daarom ook mensenwerk. Bij alle werkzaamheden waar Hart voor Verkeer bij betrokken is, staat de mens centraal. Elk advies is gebaseerd op menselijke logica en de resultaten komen, in samenwerking en met draagvlak, door mensen tot stand.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF481d39),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Onze missie
                      const Text(
                        'Op een missie',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF481d39),
                          fontFamily: 'Oswald',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hart voor Verkeer is een adviesbureau. Het \'Hart\' staat zowel voor mensen in het verkeer als projecten waar we in geloven. Wij adviseren, stimuleren en organiseren samenwerking in duurzame en veilige mobiliteit. Wij streven in al onze oplossingen naar slimme, schone en efficiënte verplaatsingen en nul verkeersslachtoffers. Ofwel, veilig en bewust van A naar B.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF481d39),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Ervaring
                      const Text(
                        'Ervaring',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF481d39),
                          fontFamily: 'Oswald',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hart voor Verkeer staat voor ruim 25 jaar verkeers- en mobiliteitsadvisering. Wij hebben zowel ervaring in de advieswereld als bij de overheid en bij kennisinstituten. De adviseurs van Hart voor Verkeer zijn breed inzetbaar op uiteenlopende mobiliteitsvraagstukken en kunnen verschillende rollen vervullen: van adviseur tot procesbegeleider, van coach tot organisator van evenementen of als ontwikkelaar van verkeers(veiligheids)producten.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF481d39),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}