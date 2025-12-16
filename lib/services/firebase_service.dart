import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check of een username al bestaat
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final doc = await _firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Username check timed out');
            },
          );

      // Als document bestaat, is username NIET beschikbaar
      // Als document niet bestaat, is username WEL beschikbaar
      return !doc.exists;
    } on TimeoutException catch (e) {
      print('Timeout checking username: $e');
      // Bij timeout, gooi de error door zodat de caller kan beslissen wat te doen
      rethrow;
    } catch (e) {
      print('Error checking username: $e');
      // Gooi andere errors ook door
      rethrow;
    }
  }

  /// Maak een nieuw gebruikersaccount aan
  Future<Map<String, dynamic>> createAccount({
    required String username,
    required int avatar,
    required String ageCategory,
  }) async {
    try {
      // Check eerst of username beschikbaar is
      bool isAvailable;
      try {
        isAvailable = await isUsernameAvailable(username);
      } catch (e) {
        print('Could not verify username availability: $e');
        // Als we de beschikbaarheid niet kunnen checken, gaan we door
        // De username wordt later geclaimd, en als die al bestaat krijgen we een error
        isAvailable = true;
      }

      if (!isAvailable) {
        return {
          'success': false,
          'error': 'Deze gebruikersnaam is al in gebruik',
        };
      }

      // ⭐ Check of user al ingelogd is
      final currentUser = _auth.currentUser;
      String uid;

      if (currentUser != null) {
        // User is al ingelogd, gebruik die UID
        uid = currentUser.uid;
        
        // Check of deze UID al een account heeft
        final existingUser = await _firestore.collection('users').doc(uid).get();
        if (existingUser.exists) {
          return {
            'success': false,
            'error': 'Je hebt al een account aangemaakt',
          };
        }
      } else {
        // Maak nieuwe anonymous user aan
        final userCredential = await _auth.signInAnonymously();
        uid = userCredential.user!.uid;
      }

      // Sla gebruikersdata op in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'username': username,
        'avatar': avatar,
        'ageCategory': ageCategory,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Reserveer de username
      await _firestore.collection('usernames').doc(username.toLowerCase()).set({
        'username': username,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'uid': uid,
      };
    } catch (e) {
      print('Error creating account: $e');
      return {
        'success': false,
        'error': 'Er is een fout opgetreden bij het aanmaken van je account',
      };
    }
  }

  /// Haal gebruikersdata op
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Check of de huidige gebruiker is ingelogd
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Haal de huidige gebruiker UID op
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Log uit (verwijdert lokale authenticatie, maar niet de Firestore data)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}