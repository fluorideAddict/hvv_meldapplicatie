import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Pin een locatie
  Future<bool> pinLocation({
    required double latitude,
    required double longitude,
    String? note,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ No user logged in');
        return false;
      }

      // Check hoeveel pins de gebruiker al heeft (max 10)
      final existingPins = await _firestore
          .collection('pinned_locations')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (existingPins.docs.length >= 10) {
        print('❌ Maximum aantal pins bereikt (10)');
        return false;
      }

      // Maak nieuwe pin
      await _firestore.collection('pinned_locations').add({
        'userId': currentUser.uid,
        'latitude': latitude,
        'longitude': longitude,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Location pinned successfully');
      return true;
    } catch (e) {
      print('❌ Error pinning location: $e');
      return false;
    }
  }

  /// Haal alle pins van de gebruiker op
  Stream<QuerySnapshot> getUserPins() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('pinned_locations')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Verwijder een pin
  Future<void> deletePin(String pinId) async {
    try {
      await _firestore.collection('pinned_locations').doc(pinId).delete();
      print('✅ Pin deleted successfully');
    } catch (e) {
      print('❌ Error deleting pin: $e');
    }
  }

  /// Tel het aantal pins van de gebruiker
  Future<int> getPinCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final snapshot = await _firestore
          .collection('pinned_locations')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error counting pins: $e');
      return 0;
    }
  }

  /// Cleanup oude pins (ouder dan 7 dagen)
  Future<void> cleanupOldPins() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final oldPins = await _firestore
          .collection('pinned_locations')
          .where('userId', isEqualTo: currentUser.uid)
          .where('createdAt', isLessThan: Timestamp.fromDate(sevenDaysAgo))
          .get();

      for (var doc in oldPins.docs) {
        await doc.reference.delete();
      }

      print('✅ Cleaned up ${oldPins.docs.length} old pins');
    } catch (e) {
      print('❌ Error cleaning up old pins: $e');
    }
  }
}