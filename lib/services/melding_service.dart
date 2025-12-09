import 'dart:io';
import 'dart:math' show cos, pi;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/melding_model.dart';
import 'storage_service.dart';

class MeldingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> createMelding({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    List<File>? photoFiles,
  }) async {
    try {
      print('📝 Starting melding creation...');

      // Check of gebruiker ingelogd is
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'error': 'Je moet ingelogd zijn om een melding te maken',
        };
      }

      // Haal gebruikersdata op
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        return {
          'success': false,
          'error': 'Gebruikersprofiel niet gevonden',
        };
      }

      final username = userDoc.data()?['username'] ?? 'Onbekend';

      // Maak eerst een melding document aan om een ID te krijgen
      final meldingRef = _firestore.collection('meldingen').doc();
      final meldingId = meldingRef.id;

      print('📤 Uploading photos...');
      // Upload foto's als die er zijn
      List<String> photoUrls = [];
      if (photoFiles != null && photoFiles.isNotEmpty) {
        photoUrls = await _storageService.uploadMultiplePhotos(
          files: photoFiles,
          userId: currentUser.uid,
          meldingId: meldingId,
        );
        print('✅ ${photoUrls.length} photos uploaded');
      }

      // Maak de melding aan
      final melding = Melding(
        id: meldingId,
        userId: currentUser.uid,
        username: username,
        category: category,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        photoUrls: photoUrls,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      print('💾 Saving melding to Firestore...');
      // Sla op in Firestore
      await meldingRef.set(melding.toFirestore());

      print('✅ Melding created successfully!');
      return {
        'success': true,
        'meldingId': meldingId,
        'melding': melding,
      };
    } catch (e) {
      print('❌ Error creating melding: $e');
      return {
        'success': false,
        'error': 'Er is een fout opgetreden bij het aanmaken van de melding: $e',
      };
    }
  }

  Stream<List<Melding>> getUserMeldingen() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('meldingen')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Melding.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Melding>> getAllMeldingen({int? limit}) {
    Query query = _firestore
        .collection('meldingen')
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Melding.fromFirestore(doc)).toList();
    });
  }

  Future<Melding?> getMelding(String meldingId) async {
    try {
      final doc = await _firestore.collection('meldingen').doc(meldingId).get();
      if (!doc.exists) return null;

      return Melding.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting melding: $e');
      return null;
    }
  }
  Future<bool> updateMelding(String meldingId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('meldingen').doc(meldingId).update(updates);
      print('✅ Melding updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating melding: $e');
      return false;
    }
  }
  Future<bool> deleteMelding(String meldingId) async {
    try {
      print('🗑️ Deleting melding...');

      // Haal eerst de melding op om de foto URLs te krijgen
      final melding = await getMelding(meldingId);
      if (melding == null) {
        return false;
      }

      // Verwijder foto's uit storage
      if (melding.photoUrls.isNotEmpty) {
        print('🗑️ Deleting ${melding.photoUrls.length} photos...');
        await _storageService.deleteMultiplePhotos(melding.photoUrls);
      }

      // Verwijder melding document
      await _firestore.collection('meldingen').doc(meldingId).delete();

      print('✅ Melding deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting melding: $e');
      return false;
    }
  }
  Future<int> countUserMeldingen({String? userId}) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) return 0;

      final snapshot = await _firestore
          .collection('meldingen')
          .where('userId', isEqualTo: uid)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error counting meldingen: $e');
      return 0;
    }
  }

  Stream<List<Melding>> getMeldingenInArea({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) {

    final latDelta = radiusKm / 111.0; // 1 degree latitude ≈ 111 km
    final lngDelta = radiusKm / (111.0 * cos(centerLat * pi / 180.0));

    return _firestore
        .collection('meldingen')
        .where('latitude', isGreaterThan: centerLat - latDelta)
        .where('latitude', isLessThan: centerLat + latDelta)
        .snapshots()
        .map((snapshot) {
      // Filter verder op longitude in de app (Firestore kan maar 1 range query)
      return snapshot.docs
          .map((doc) => Melding.fromFirestore(doc))
          .where((melding) {
        final lngDiff = (melding.longitude - centerLng).abs();
        return lngDiff < lngDelta;
      })
          .toList();
    });
  }

  Stream<List<Melding>> getMeldingenByCategory(String category) {
    return _firestore
        .collection('meldingen')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Melding.fromFirestore(doc)).toList();
    });
  }
}