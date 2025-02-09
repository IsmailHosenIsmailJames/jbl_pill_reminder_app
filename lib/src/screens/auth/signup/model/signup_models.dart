import 'dart:convert';

class UserInfoModel {
  final String name;
  final int age;
  final String gender;
  final String division;
  final String district;
  final String thana;
  final String phone;
  final String password;

  UserInfoModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.division,
    required this.district,
    required this.thana,
    required this.phone,
    required this.password,
  });

  UserInfoModel copyWith({
    String? name,
    int? age,
    String? gender,
    String? division,
    String? district,
    String? thana,
    String? phone,
    String? password,
  }) =>
      UserInfoModel(
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        division: division ?? this.division,
        district: district ?? this.district,
        thana: thana ?? this.thana,
        phone: phone ?? this.phone,
        password: password ?? this.password,
      );

  factory UserInfoModel.fromJson(String str) =>
      UserInfoModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserInfoModel.fromMap(Map<String, dynamic> json) => UserInfoModel(
        name: json['name'],
        age: json['age'],
        gender: json['gender'],
        division: json['division'],
        district: json['district'],
        thana: json['thana'],
        phone: json['phone'],
        password: json['password'],
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'age': age,
        'gender': gender,
        'division': division,
        'district': district,
        'thana': thana,
        'phone': phone,
        'password': password,
      };
}
