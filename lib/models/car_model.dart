class CarInfo {
  String? id;
  String? vehiclefullname;

  String? year;
  String? transmission;
  String? price;
  String? status;

  CarInfo({
    required this.id,
    required this.vehiclefullname,
    required this.year,
    required this.transmission,
    required this.price,
    this.status,

  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      id: json['id'],
      vehiclefullname: json['vehiclefullname'],
      year: json['year'],
      transmission: json['transmission'],
      price: json['price'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehiclefullname': vehiclefullname,
      'year': year,
      'transmission': transmission,
      'price': price,
      'status': status,
    };
  }
}
