import 'dart:convert';

class User {
  String id;
  String name;
  String email;
  String mobile;
  String age;
  String gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.age,
    required this.gender,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? age,
    String? gender,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        mobile: mobile ?? this.mobile,
        age: age ?? this.age,
        gender: gender ?? this.gender,
      );

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        age: json["age"],
        gender: json["gender"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "age": age,
        "gender": gender,
      };
}
