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
    };
  }
}
