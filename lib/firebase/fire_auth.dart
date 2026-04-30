import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentme/models/car_model.dart';
import 'package:rentme/models/user_model.dart';
import 'package:geolocator/geolocator.dart';

class FireAuth {
  /// Request permission and get current user location
  Future<Map<String, double>> getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied");
    }

    Position pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    );
    return {'latitude': pos.latitude, 'longitude': pos.longitude};
  }

  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  /// Create or update user document with location included
  static Future createUser(
    String phonenumber,
    String agencyname,
    String country,
    String province,
    String townhall,
  ) async {
    User user = auth.currentUser!;

    // Get current image if exists
    final doc = await firebaseFirestore.collection('users').doc(user.uid).get();
    String currentImg = doc.data()?['img'] ?? '';

    // Get user location
    Map<String, double> location = await FireAuth().getUserLocation();

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
      isFirstTime: false,
      latitude: location['latitude'],
      longitude: location['longitude'],
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
    String currency, // ✅ spelling fixed
  ) async {
    User user = auth.currentUser!;
    CarInfo carInfo = CarInfo(
      id: vehicleId,
      vehiclefullname: vehiclefullname,
      year: year,
      transmission: transmission,
      price: price,
      img: img,
      NameAndYear: "$vehiclefullname $year",
      currency: currency, // ✅ now included in the model
    );

    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .collection('cars')
        .doc(vehicleId)
        .set(carInfo.toJson());
  }
}
