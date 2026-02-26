class CarInfo {
  String? id;
  String? vehiclefullname;
  String? year;
  String? transmission;
  String? price;
  String? status;
  String? img;
  List<String>? images;

  CarInfo({
    required this.id,
    required this.vehiclefullname,
    required this.year,
    required this.transmission,
    required this.price,
    required this.img,
    this.status = 'Avaiable',
    this.images,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      id: json['id'],
      vehiclefullname: json['vehiclefullname'],
      year: json['year'],
      transmission: json['transmission'],
      price: json['price'],
      img: json['img'],
      status: json['status'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehiclefullname': vehiclefullname,
      'year': year,
      'transmission': transmission,
      'price': price,
      'img': img,
      'status': status,
      'images': images,
    };
  }
}
