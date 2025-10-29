import 'package:flutter/material.dart';

class AccountAanmakenScreen extends StatefulWidget {
  const AccountAanmakenScreen({Key? key}) : super(key: key);

  @override
  State<AccountAanmakenScreen> createState() => _AccountAanmakenScreenState();
}

class _AccountAanmakenScreenState extends State<AccountAanmakenScreen> {
  int selectedAvatar = 1;
  final TextEditingController usernameController = TextEditingController();
  String? selectedAge;

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
                  'images/logoHVV2.png',
                  height: 60,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Account aanmaken',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF481d39),
                  fontFamily: 'Oswald',
                ),
              ),
              const SizedBox(height: 30),
              // Avatar selector
              const Text(
                'Kies een avatar',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF945a7f),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (selectedAvatar > 0) selectedAvatar--;
                      });
                    },
                    icon: const Icon(Icons.chevron_left, size: 32),
                    color: const Color(0xFF481d39),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFfcb523),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF481d39),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (selectedAvatar < 2) selectedAvatar++;
                      });
                    },
                    icon: const Icon(Icons.chevron_right, size: 32),
                    color: const Color(0xFF481d39),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Gebruikersnaam
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gebruikersnaam',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF481d39),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFeae2d5),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Leeftijdscategorie
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Leeftijdscategorie',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF481d39),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFeae2d5),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF481d39),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton<String>(
                  value: selectedAge,
                  hint: const Text('Selecteer leeftijd'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '18-25', child: Text('18-25')),
                    DropdownMenuItem(value: '26-35', child: Text('26-35')),
                    DropdownMenuItem(value: '36-50', child: Text('36-50')),
                    DropdownMenuItem(value: '51+', child: Text('51+')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAge = value;
                    });
                  },
                ),
              ),
              const Spacer(),
              // Verder button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigatie naar volgende pagina
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF481d39),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Verder',
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

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }
}