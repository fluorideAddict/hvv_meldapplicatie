import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import '../services/pin_service.dart';
import 'profiel_screen.dart';
import 'inbox_screen.dart';
import 'meldingen/melding_maken_screen.dart';

class PinnedLocationsScreen extends StatefulWidget {
  const PinnedLocationsScreen({Key? key}) : super(key: key);

  @override
  State<PinnedLocationsScreen> createState() => _PinnedLocationsScreenState();
}

class _PinnedLocationsScreenState extends State<PinnedLocationsScreen> {
  final PinService _pinService = PinService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return _buildEmptyState('Niet ingelogd');
    }

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
          // Content area met pins
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _pinService.getUserPins(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('❌ Pins error: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Color(0xFFbd213f),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Er is een fout opgetreden',
                            style: TextStyle(
                              color: Color(0xFF481d39),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF481d39),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF481d39),
                    ),
                  );
                }

                final pins = snapshot.data?.docs ?? [];

                if (pins.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.push_pin_outlined,
                          size: 80,
                          color: Color(0xFF481d39),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Geen gepinde locaties',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF481d39),
                            fontFamily: 'Oswald',
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Pin een locatie op de kaart om later een melding te maken',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF481d39),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pins.length,
                  itemBuilder: (context, index) {
                    final pin = pins[index];
                    return _buildPinCard(pin);
                  },
                );
              },
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
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(
                        Icons.home,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    // Pin icoon (actief)
                    _buildPinIconWithBadge(),
                    // Inbox/berichten icoon met badge
                    _buildInboxIconWithBadge(),
                    // Profiel icoon
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
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

  Widget _buildEmptyState(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFeae2d5),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF481d39),
          ),
        ),
      ),
    );
  }

  Widget _buildPinCard(QueryDocumentSnapshot pin) {
    final data = pin.data() as Map<String, dynamic>;
    final latitude = data['latitude'] ?? 0.0;
    final longitude = data['longitude'] ?? 0.0;
    final note = data['note'] as String?;
    final createdAt = data['createdAt'] as Timestamp?;

    // Format tijd
    String timeAgo = 'Zojuist';
    if (createdAt != null) {
      final now = DateTime.now();
      final pinTime = createdAt.toDate();
      final difference = now.difference(pinTime);

      if (difference.inMinutes < 1) {
        timeAgo = 'Zojuist';
      } else if (difference.inMinutes < 60) {
        timeAgo = '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuut' : 'minuten'} geleden';
      } else if (difference.inHours < 24) {
        timeAgo = '${difference.inHours} ${difference.inHours == 1 ? 'uur' : 'uur'} geleden';
      } else if (difference.inDays < 7) {
        timeAgo = '${difference.inDays} ${difference.inDays == 1 ? 'dag' : 'dagen'} geleden';
      } else {
        final weeks = (difference.inDays / 7).floor();
        timeAgo = '$weeks ${weeks == 1 ? 'week' : 'weken'} geleden';
      }
    }

    return Dismissible(
      key: Key(pin.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      onDismissed: (direction) async {
        await _pinService.deletePin(pin.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pin verwijderd'),
            backgroundColor: Color(0xFF481d39),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeldingMakenScreen(
                pinnedLatitude: latitude,
                pinnedLongitude: longitude,
                pinId: pin.id,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFf5a623).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icoon cirkel
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFf5a623).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.push_pin,
                  color: Color(0xFFf5a623),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Tekst content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note ?? 'Gepinde locatie',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                        color: Color(0xFF481d39),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Toon adres ipv coordinaten - NIEUW
                    FutureBuilder<String>(
                      future: _getAddressFromCoordinates(latitude, longitude),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            'Adres laden...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF481d39),
                              fontFamily: 'Offside',
                            ),
                          );
                        }
                        return Text(
                          snapshot.data ?? 'Locatie onbekend',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF481d39),
                            fontFamily: 'Offside',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF481d39).withOpacity(0.6),
                        fontFamily: 'Offside',
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF481d39),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NIEUWE METHODE - Adres ophalen
  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark placemark = placemarks[0];

      // Als er een straatnaam is
      if (placemark.street != null && placemark.street!.isNotEmpty) {
        return '${placemark.street}, ${placemark.locality ?? placemark.subAdministrativeArea ?? ''}';
      }

      // Als er geen straat is (bijvoorbeeld op een weg/snelweg)
      if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
        return '${placemark.thoroughfare}, ${placemark.locality ?? placemark.subAdministrativeArea ?? ''}';
      }

      // Als helemaal niks, gebruik stad/gebied
      return '${placemark.locality ?? placemark.subAdministrativeArea ?? 'Onbekende locatie'}';
    } catch (e) {
      print('Error getting address: $e');
      return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
    }
  }

  Widget _buildPinIconWithBadge() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return IconButton(
        onPressed: () {
          // Al op pins screen
        },
        icon: const Icon(
          Icons.push_pin,
          color: Colors.black,
          size: 32,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('pinned_locations')
          .where('userId', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final pinCount = snapshot.data?.docs.length ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                // Al op pins screen
              },
              icon: const Icon(
                Icons.push_pin,
                color: Colors.black,
                size: 32,
              ),
            ),
            if (pinCount > 0)
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
                      pinCount > 9 ? '9+' : '$pinCount',
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
}