class ChatUser {
  String? id;
  String? email;
  String? username;
  String? phonenumber;
  String? agencyname;
  String? country;
  String? province;
  String? townhall;
  String? img;
  bool? isFirstTime;
  double? latitude;
  double? longitude;
  ChatUser({
    required this.id,
    required this.email,
    required this.username,
    required this.phonenumber,
    required this.agencyname,
    required this.country,
    required this.province,
    required this.townhall,
    required this.img,
    this.isFirstTime = true,
      this.latitude,
      this.longitude,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      phonenumber: json['phonenumber'],
      agencyname: json['agencyname'],
      country: json['country'],
      province: json['province'],
      townhall: json['townhall'],
      img: json['img'],
      isFirstTime: json['isFirstTime'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phonenumber': phonenumber,
      'agencyname': agencyname,
      'country': country,
      'province': province,
      'townhall': townhall,
      'img': img,
      'isFirstTime': isFirstTime,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
