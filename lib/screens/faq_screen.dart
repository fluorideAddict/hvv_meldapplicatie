import 'package:flutter/material.dart';
import 'privacy_screen.dart';
import 'over_ons_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // List of FAQ items - currently empty, ready to be populated
  final List<Map<String, String>> _faqItems = [
    // Example structure:
    // {
    //   'question': 'Hoe maak ik een melding?',
    //   'answer': 'Druk op de grote rode knop in het midden...',
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeae2d5),
      body: Column(
        children: [
          // Rode header met logo en terug knop
          Container(
            color: const Color(0xFFbd213f),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Terug knop
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 32,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // Logo in het midden
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logoHVV2.png',
                        height: 50,
                      ),
                    ),
                  ),
                  // Placeholder voor symmetrie
                  const SizedBox(width: 32),
                ],
              ),
            ),
          ),
          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titel
                  const Text(
                    'Veelgestelde vragen',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF481d39),
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hier vind je antwoorden op veelgestelde vragen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF481d39),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // FAQ items (momenteel leeg)
                  if (_faqItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        child: Column(
                          children: [
                            Icon(
                              Icons.question_answer_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'FAQ items komen binnenkort',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontFamily: 'Oswald',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._faqItems.map((faq) => _buildFaqItem(
                      question: faq['question']!,
                      answer: faq['answer']!,
                    )),

                  // Spacing before additional links
                  const SizedBox(height: 32),

                  // Privacyverklaring button
                  _buildNavigationButton(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacyverklaring',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyScreen(viewOnly: true),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Over ons button
                  _buildNavigationButton(
                    icon: Icons.info_outline,
                    label: 'Over ons',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OverOnsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF481d39),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF481d39),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF481d39),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF481d39),
            ),
          ),
          iconColor: const Color(0xFF481d39),
          collapsedIconColor: const Color(0xFF481d39),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF481d39),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}