import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profiel_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Doe niets in initState - laat notificaties gewoon zichtbaar
  }

  @override
  void dispose() {
    // Markeer als gelezen wanneer gebruiker de inbox verlaat
    _markAllAsReadOnExit();
    super.dispose();
  }

  Future<void> _markAllAsReadOnExit() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Haal alle ongelezen notificaties op
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      // Markeer ze allemaal als gelezen
      for (var doc in unreadNotifications.docs) {
        await doc.reference.update({'isRead': true});
      }

      print('✅ All notifications marked as read on exit');
    } catch (e) {
      print('❌ Error marking notifications as read: $e');
    }
  }

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
          // Content area met notificaties
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('notifications')
                  .where('userId', isEqualTo: currentUser.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('❌ Inbox error: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Color(0xFFbd213f),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Er is een fout opgetreden',
                            style: TextStyle(
                              color: Color(0xFF481d39),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF481d39),
                    ),
                  );
                }

                final notifications = snapshot.data?.docs ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Color(0xFF481d39),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Geen notificaties',
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
                            'Je ontvangt hier updates over je meldingen',
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
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification);
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
                    // Inbox/berichten icoon (actief)
                    IconButton(
                      onPressed: () {
                        // Al op inbox
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
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF481d39),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(QueryDocumentSnapshot notification) {
    final data = notification.data() as Map<String, dynamic>;
    final isRead = data['isRead'] ?? false;
    final type = data['type'] ?? 'report_created';
    final title = data['title'] ?? 'Notificatie';
    final message = data['message'] ?? '';
    final createdAt = data['createdAt'] as Timestamp?;

    // Bepaal icoon en kleur op basis van type
    IconData icon;
    Color accentColor;

    switch (type) {
      case 'like':
        icon = Icons.thumb_up;
        accentColor = const Color(0xFFf5a623); // Geel/oranje
        break;
      case 'report_created':
        icon = Icons.check_circle;
        accentColor = const Color(0xFF4CAF50); // Groen
        break;
      case 'report_update':
        icon = Icons.notifications_active;
        accentColor = const Color(0xFFbd213f); // Rood
        break;
      default:
        icon = Icons.notifications;
        accentColor = const Color(0xFF481d39); // Paars
    }

    // Format tijd
    String timeAgo = 'Zojuist';
    if (createdAt != null) {
      final now = DateTime.now();
      final notificationTime = createdAt.toDate();
      final difference = now.difference(notificationTime);

      if (difference.inMinutes < 1) {
        timeAgo = 'Zojuist';
      } else if (difference.inMinutes < 60) {
        timeAgo = '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuut' : 'minuten'} geleden';
      } else if (difference.inHours < 24) {
        timeAgo = '${difference.inHours} ${difference.inHours == 1 ? 'uur' : 'uur'} geleden';
      } else if (difference.inDays < 7) {
        timeAgo = '${difference.inDays} ${difference.inDays == 1 ? 'dag' : 'dagen'} geleden';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        timeAgo = '$weeks ${weeks == 1 ? 'week' : 'weken'} geleden';
      } else {
        final months = (difference.inDays / 30).floor();
        timeAgo = '$months ${months == 1 ? 'maand' : 'maanden'} geleden';
      }
    }

    return Dismissible(
      key: Key(notification.id),
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
        // Verwijder notificatie uit Firestore
        await _firestore.collection('notifications').doc(notification.id).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificatie verwijderd'),
            backgroundColor: Color(0xFF481d39),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          // Optioneel: doe iets bij tap (nu niet nodig omdat al gelezen)
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: isRead
                ? null
                : Border.all(
              color: accentColor.withOpacity(0.5),
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
                  color: accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Tekst content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Oswald',
                              color: Color(0xFF481d39),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF481d39),
                        fontFamily: 'Offside',
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}