import 'package:cloud_firestore/cloud_firestore.dart';

class CarInfo {
  String? id;
  String? vehiclefullname;
  String? year;
  String? NameAndYear;
  String? transmission;
  String? price;
  String? status;
  String? img;
  List<String>? images;
  final DateTime? rentedAt;
  int? avaiableIn;

  CarInfo({
    required this.id,
    required this.vehiclefullname,
    required this.NameAndYear,
    required this.year,
    required this.transmission,
    required this.price,
    required this.img,
    this.status = 'Avaiable',
    this.images,
    this.rentedAt,
    this.avaiableIn = 0,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      id: json['id'],
      vehiclefullname: json['vehiclefullname'],
      NameAndYear: json['NameAndYear'],
      year: json['year'],
      transmission: json['transmission'],
      price: json['price'],
      img: json['img'],
      status: json['status'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      rentedAt: json['rentedAt'] != null
          ? (json['rentedAt'] as Timestamp)
                .toDate() // ✅ convert Timestamp → DateTime
          : null,
      avaiableIn: json['avaiableIn'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehiclefullname': vehiclefullname,
      'NameAndYear': NameAndYear,
      'year': year,
      'transmission': transmission,
      'price': price,
      'img': img,
      'status': status,
      'images': images,
      'rentedAt': rentedAt != null
          ? Timestamp.fromDate(rentedAt!)
          : null, // ✅ convert back
      'avaiableIn': avaiableIn,
    };
  }
}
