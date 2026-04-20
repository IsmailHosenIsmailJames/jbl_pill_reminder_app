class UserEntity {
  final int id;
  final String mobile;
  final String? name;
  final int? age;
  final String? division;
  final String? district;
  final String? upazila;
  final String? profilePhoto;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.id,
    required this.mobile,
    this.name,
    this.age,
    this.division,
    this.district,
    this.upazila,
    this.profilePhoto,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
