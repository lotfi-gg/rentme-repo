import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentme/models/car_model.dart';
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
    bool isFirstTime,
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
      isFirstTime: isFirstTime,
    );

    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson(), SetOptions(merge: true));
  }
}

class FireCar {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  /// Create a new car under the current user's "cars" subcollection
  static Future createCar(
    String vehicleId,
    String vehiclefullname,
    String year,
    String transmission,
    String price,
    String img,
  ) async {
    User user = auth.currentUser!;
    CarInfo carInfo = CarInfo(
      id: vehicleId,
      vehiclefullname: vehiclefullname,
      year: year,
      transmission: transmission,
      price: price,
      img: img,
    );

    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .collection('cars')
        .doc(vehicleId)
        .set(carInfo.toJson());
  }
}
