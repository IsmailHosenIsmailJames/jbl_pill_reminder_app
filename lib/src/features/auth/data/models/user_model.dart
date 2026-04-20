import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/user_entity.dart";

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.mobile,
    super.name,
    super.age,
    super.division,
    super.district,
    super.upazila,
    super.profilePhoto,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? json;
    return UserModel(
      id: data["id"],
      mobile: data["mobile"],
      name: data["name"],
      age: data["age"],
      division: data["division"],
      district: data["district"],
      upazila: data["upazila"],
      profilePhoto: data["profilePhoto"],
      status: data["status"],
      createdAt: DateTime.parse(data["createdAt"]),
      updatedAt: DateTime.parse(data["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "mobile": mobile,
      "name": name,
      "age": age,
      "division": division,
      "district": district,
      "upazila": upazila,
      "profilePhoto": profilePhoto,
      "status": status,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
