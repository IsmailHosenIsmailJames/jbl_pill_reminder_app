import 'dart:convert';

class MedicineModel {
  String brandName;
  String genericName;
  String strength;
  String dosageDescription;

  MedicineModel({
    required this.brandName,
    required this.genericName,
    required this.strength,
    required this.dosageDescription,
  });

  MedicineModel copyWith({
    String? brandName,
    String? genericName,
    String? strength,
    String? dosageDescription,
  }) =>
      MedicineModel(
        brandName: brandName ?? this.brandName,
        genericName: genericName ?? this.genericName,
        strength: strength ?? this.strength,
        dosageDescription: dosageDescription ?? this.dosageDescription,
      );

  factory MedicineModel.fromJson(String str) =>
      MedicineModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MedicineModel.fromMap(Map<String, dynamic> json) => MedicineModel(
        brandName: json['brandName'],
        genericName: json['genericName'],
        strength: json['strength'],
        dosageDescription: json['dosageDescription'],
      );

  Map<String, dynamic> toMap() => {
        'brandName': brandName,
        'genericName': genericName,
        'strength': strength,
        'dosageDescription': dosageDescription,
      };
}
