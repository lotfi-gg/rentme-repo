import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStorage {
  final FirebaseStorage fireStorage = FirebaseStorage.instance;

  Future<String> updateprofilepicture({required File file}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ext = file.path.split('.').last;
    final ref = fireStorage.ref().child(
      'profile/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );

    try {
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();
      print('the image url ==> $imageUrl');
      return imageUrl; // ✅ only return URL
    } catch (e) {
      print('error while uploading profile image --> $e');
      return '';
    }
  }

  Future<String> uploadCarImage(File imageFile, String carId) async {
    try {
      final ref = fireStorage.ref().child('cars/$carId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading car image: $e');
      return '';
    }
  }
}
