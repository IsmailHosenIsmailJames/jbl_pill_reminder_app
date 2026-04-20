import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/auth_entity.dart";

class AuthModel extends AuthEntity {
  AuthModel({
    required super.id,
    required super.accessToken,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // The API response has the data inside a 'data' field
    final data = json["data"] ?? json;
    return AuthModel(
      id: data["id"],
      accessToken: data["access_token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "access_token": accessToken,
    };
  }
}
