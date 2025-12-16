import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'start_screen.dart';
import 'meldingen/mijn_meldingen_screen.dart';
import 'inbox_screen.dart';

class ProfielScreen extends StatefulWidget {
  const ProfielScreen({Key? key}) : super(key: key);

  @override
  State<ProfielScreen> createState() => _ProfielScreenState();
}

class _ProfielScreenState extends State<ProfielScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = 'Laden...';
  String ageCategory = 'Laden...';
  int avatar = 1;
  String memberSince = 'Laden...';
  int reportCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('🔍 Starting to load user data...');

    try {
      final currentUser = _auth.currentUser;
      print('👤 Current user: ${currentUser?.uid}');

      if (currentUser == null) {
        print('❌ No user logged in!');
        setState(() {
          username = 'Niet ingelogd';
          ageCategory = '-';
          memberSince = '-';
        });
        return;
      }

      print('📡 Fetching user data from Firestore...');
      final userData = await _firestore.collection('users').doc(currentUser.uid).get();
      print('📄 User document exists: ${userData.exists}');

      if (userData.exists) {
        final data = userData.data()!;
        print('✅ User data: $data');

        // Bereken aantal meldingen
        print('📊 Counting reports...');
        final reportsSnapshot = await _firestore
            .collection('meldingen')
            .where('userId', isEqualTo: currentUser.uid)
            .get();
        print('📈 Reports count: ${reportsSnapshot.docs.length}');

        // Format datum
        final createdAt = data['createdAt'] as Timestamp?;
        String formattedDate = 'Onbekend';
        if (createdAt != null) {
          final date = createdAt.toDate();
          final months = ['januari', 'februari', 'maart', 'april', 'mei', 'juni',
            'juli', 'augustus', 'september', 'oktober', 'november', 'december'];
          formattedDate = '${date.day} ${months[date.month - 1]} ${date.year}';
        }

        setState(() {
          username = data['username'] ?? 'Onbekend';
          ageCategory = data['ageCategory'] ?? 'Onbekend';
          avatar = data['avatar'] ?? 1;
          memberSince = formattedDate;
          reportCount = reportsSnapshot.docs.length;
        });

        print('✅ Data loaded successfully!');
      } else {
        print('❌ User document does not exist!');
        setState(() {
          username = 'Geen data';
          ageCategory = 'Geen data';
          memberSince = 'Geen data';
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        username = 'Fout: $e';
        ageCategory = '-';
        memberSince = '-';
      });
    }
  }

  String _getAgeCategoryDisplayText(String value) {
    switch (value) {
      case 'younger-16':
        return 'Jonger dan 16';
      case '16-24':
        return '16 - 24 jaar';
      case '25-34':
        return '25 - 34 jaar';
      case '35-44':
        return '35 - 44 jaar';
      case '45-54':
        return '45 - 54 jaar';
      case '55-64':
        return '55 - 64 jaar';
      case '65-plus':
        return '65+';
      default:
        return value;
    }
  }

  void _showAgeCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFeae2d5),
          title: const Text(
            'Leeftijdscategorie wijzigen',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF481d39),
              fontFamily: 'Oswald',
              fontSize: 22,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAgeCategoryOption('younger-16', 'Jonger dan 16'),
                const SizedBox(height: 12),
                _buildAgeCategoryOption('16-24', '16 - 24 jaar'),
                const SizedBox(height: 12),
                _buildAgeCategoryOption('25-34', '25 - 34 jaar'),
                const SizedBox(height: 12),
                _buildAgeCategoryOption('35-44', '35 - 44 jaar'),
                const SizedBox(height: 12),
                _buildAgeCategoryOption('45-54', '45 - 54 jaar'),
                const SizedBox(height: 12),
                _buildAgeCategoryOption('55-64', '55 - 64 jaar'),
                const SizedBox(height: 12),
                _buildAgeCategoryOption('65-plus', '65+'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Annuleren',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgeCategoryOption(String value, String displayText) {
    final isSelected = value == ageCategory;

    return InkWell(
      onTap: () async {
        try {
          final currentUser = _auth.currentUser;
          if (currentUser == null) return;

          await _firestore.collection('users').doc(currentUser.uid).update({
            'ageCategory': value,
          });

          setState(() {
            ageCategory = value;
          });

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Leeftijdscategorie bijgewerkt!'),
              backgroundColor: const Color(0xFF481d39),
            ),
          );
        } catch (e) {
          print('Error updating age category: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Er is een fout opgetreden'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF481d39), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: const Color(0xFF481d39),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF481d39),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFeae2d5),
          title: const Text(
            'Account verwijderen',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF481d39),
              fontFamily: 'Oswald',
              fontSize: 22,
            ),
          ),
          content: const Text(
            'Weet je zeker dat je je account wilt verwijderen? Dit kan niet ongedaan worden gemaakt en al je gegevens worden permanent verwijderd.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF481d39),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Annuleren',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final currentUser = _auth.currentUser;
                  if (currentUser == null) return;

                  // Haal eerst de username op voor het verwijderen
                  final userData = await _firestore.collection('users').doc(currentUser.uid).get();
                  final usernameToDelete = userData.data()?['username'];

                  // Verwijder gebruikersdata uit Firestore
                  await _firestore.collection('users').doc(currentUser.uid).delete();

                  // Verwijder username reservering
                  if (usernameToDelete != null) {
                    await _firestore.collection('usernames').doc(usernameToDelete.toLowerCase()).delete();
                  }

                  // Verwijder alle meldingen van de gebruiker
                  final reportsSnapshot = await _firestore
                      .collection('meldingen')
                      .where('userId', isEqualTo: currentUser.uid)
                      .get();

                  for (var doc in reportsSnapshot.docs) {
                    await doc.reference.delete();
                  }

                  // Verwijder alle notificaties van de gebruiker
                  final notificationsSnapshot = await _firestore
                      .collection('notifications')
                      .where('userId', isEqualTo: currentUser.uid)
                      .get();

                  for (var doc in notificationsSnapshot.docs) {
                    await doc.reference.delete();
                  }

                  // Log uit
                  await _auth.signOut();

                  // Sluit dialog
                  Navigator.pop(context);

                  // Navigeer naar StartScreen en verwijder alle vorige schermen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const StartScreen()),
                        (route) => false,
                  );
                } catch (e) {
                  print('Error deleting account: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Er is een fout opgetreden bij het verwijderen'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFbd213f),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verwijderen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInboxIconWithBadge() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InboxScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.inbox,
          color: Colors.black,
          size: 32,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.docs.length ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InboxScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.inbox,
                color: Colors.black,
                size: 32,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf5a623),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeae2d5),
      body: Column(
        children: [
          // Rode header met logo
          Container(
            color: const Color(0xFFbd213f),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logoHVV2.png',
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
          // Content area met Stack
          Expanded(
            child: Stack(
              children: [
                // Rechthoek die achter de footer doorloopt
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFeae2d5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 75), // Ruimte voor avatar
                        // Username
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF481d39),
                            fontFamily: 'Oswald',
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Profielinformatie container
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                // Lid sinds
                                _buildInfoRow(
                                  icon: Icons.calendar_today,
                                  label: 'Lid sinds',
                                  value: memberSince,
                                ),
                                const SizedBox(height: 16),
                                // Aantal meldingen
                                _buildInfoRow(
                                  icon: Icons.notifications_active,
                                  label: 'Meldingen geplaatst',
                                  value: reportCount.toString(),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  icon: Icons.list_alt,
                                  label: 'Mijn meldingen',
                                  value: '', // Empty value voor knop
                                  isButton: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MijnMeldingenScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Leeftijdscategorie wijzigen knop
                                _buildInfoRow(
                                  icon: Icons.cake,
                                  label: 'Leeftijdscategorie',
                                  value: _getAgeCategoryDisplayText(ageCategory),
                                  isButton: true,
                                  onTap: _showAgeCategoryDialog,
                                ),
                                const Spacer(),
                                // Verwijder account knop
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 100),
                                  child: ElevatedButton(
                                    onPressed: () => _showDeleteAccountDialog(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFbd213f),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.delete_forever,
                                          size: 24,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Account verwijderen',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Oswald',
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
                      ],
                    ),
                  ),
                ),
                // Avatar gepositioneerd op de rand
                Positioned(
                  top: 37.5,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFeae2d5),
                        border: Border.all(
                          color: const Color(0xFF481d39),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/icoon$avatar.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                // Footer op de voorgrond
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
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
                                // Pop alle schermen tot we bij home zijn
                                Navigator.popUntil(context, (route) => route.isFirst);
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
                            // Inbox/berichten icoon met badge
                            _buildInboxIconWithBadge(),
                            // Profiel icoon (actief)
                            IconButton(
                              onPressed: () {
                                // Al op profiel
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isButton = false,
    VoidCallback? onTap,
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
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF481d39),
              ),
            ),
            if (isButton)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF481d39),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}