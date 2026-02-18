import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStorage {
  final FirebaseStorage fireStorage = FirebaseStorage.instance;

  Future updateprofilepicture({required File file}) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String ext = file.path.split('.').last;

    final ref = fireStorage.ref().child(
      'profile/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );

    try {
      await ref.putFile(file);
      String imageUrl = await ref.getDownloadURL();
      print('the image url ==> $imageUrl');
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'img': imageUrl,
      });
    } catch (e) {
      print('an error while sending image --> $e');
    }
  }
}
