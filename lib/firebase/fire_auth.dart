import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentme/models/user_model.dart';

class FireAuth {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static Future createUser(
    String phonenumber,
    String agencyname,
    String country,
    String province,
    String townhall,
  ) async {
    User user = auth.currentUser!;
    final doc = await firebaseFirestore.collection('users').doc(user.uid).get();
    String currentImg = doc.data()?['img'] ?? '';
    ChatUser chatUser = ChatUser(
      id: user.uid,
      username: user.displayName ?? '',
      email: user.email ?? '',
      phonenumber: phonenumber,
      agencyname: agencyname,
      country: country,
      province: province,
      townhall: townhall,
      img: currentImg,
    );

    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson(), SetOptions(merge: true));
  }
}
