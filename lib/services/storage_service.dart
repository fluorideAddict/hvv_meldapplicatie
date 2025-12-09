import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadPhoto({
    required File file,
    required String userId,
    required String meldingId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('meldingen/$userId/$meldingId/$fileName');

      // Upload met metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'meldingId': meldingId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = await ref.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('✅ Photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading photo: $e');
      return null;
    }
  }

  Future<List<String>> uploadMultiplePhotos({
    required List<File> files,
    required String userId,
    required String meldingId,
  }) async {
    final List<String> urls = [];

    for (final file in files) {
      final url = await uploadPhoto(
        file: file,
        userId: userId,
        meldingId: meldingId,
      );
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  Future<File?> pickPhotoFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Compress om storage te besparen
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      print('❌ Error picking photo from camera: $e');
      return null;
    }
  }

   Future<File?> pickPhotoFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      print('❌ Error picking photo from gallery: $e');
      return null;
    }
  }

  Future<List<File>> pickMultiplePhotos({int maxImages = 5}) async {
    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      // Limiteer tot maxImages
      final limitedPhotos = photos.take(maxImages).toList();

      return limitedPhotos.map((photo) => File(photo.path)).toList();
    } catch (e) {
      print('❌ Error picking multiple photos: $e');
      return [];
    }
  }

  Future<bool> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      print('✅ Photo deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting photo: $e');
      return false;
    }
  }

  Future<void> deleteMultiplePhotos(List<String> photoUrls) async {
    for (final url in photoUrls) {
      await deletePhoto(url);
    }
  }

   Future<File?> showPhotoSourceDialog() async {
    // om gebruiker te laten kiezen tussen camera of galerij
    throw UnimplementedError(
      'Deze method moet in de UI layer geïmplementeerd worden met showDialog()',
    );
  }
}
