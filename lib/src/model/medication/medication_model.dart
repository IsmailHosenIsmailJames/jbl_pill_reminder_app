import 'dart:convert';

import 'package:jbl_pill_reminder_app/src/model/medication/schedule_model.dart';

class MedicationModel {
  String id;
  String? title;
  String? reason;
  List<Medicine>? medicines;
  ScheduleModel? schedule;
  Prescription? prescription;

  MedicationModel({
    required this.id,
    this.title,
    this.reason,
    this.medicines,
    this.schedule,
    this.prescription,
  });

  MedicationModel copyWith({
    String? id,
    String? title,
    String? reason,
    List<Medicine>? medicines,
    ScheduleModel? schedule,
    Prescription? prescription,
  }) =>
      MedicationModel(
        id: id ?? this.id,
        title: title ?? this.title,
        reason: reason ?? this.reason,
        medicines: medicines ?? this.medicines,
        schedule: schedule ?? this.schedule,
        prescription: prescription ?? this.prescription,
      );

  factory MedicationModel.fromJson(String str) =>
      MedicationModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MedicationModel.fromMap(Map<String, dynamic> json) => MedicationModel(
        id: json["id"],
        title: json["title"],
        reason: json["reason"],
        medicines: json["medicines"] == null
            ? []
            : List<Medicine>.from(
                json["medicines"]!.map((x) => Medicine.fromMap(x))),
        schedule: json["schedule"] == null
            ? null
            : ScheduleModel.fromMap(json["schedule"]),
        prescription: json["prescription"] == null
            ? null
            : Prescription.fromMap(json["prescription"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "reason": reason,
        "medicines": medicines == null
            ? []
            : List<dynamic>.from(medicines!.map((x) => x.toMap())),
        "schedule": schedule?.toMap(),
        "prescription": prescription?.toMap(),
      };
}

class Medicine {
  String? id;
  String? name;
  String? type;
  String? imageUrl;
  String? color;
  String? notes;

  Medicine({
    this.id,
    this.name,
    this.type,
    this.imageUrl,
    this.color,
    this.notes,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? type,
    String? imageUrl,
    String? color,
    String? notes,
  }) =>
      Medicine(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        imageUrl: imageUrl ?? this.imageUrl,
        color: color ?? this.color,
        notes: notes ?? this.notes,
      );

  factory Medicine.fromJson(String str) => Medicine.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Medicine.fromMap(Map<String, dynamic> json) => Medicine(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        imageUrl: json["image_url"],
        color: json["color"],
        notes: json["notes"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "type": type,
        "image_url": imageUrl,
        "color": color,
        "notes": notes,
      };
}

class Prescription {
  String id;
  String? imageUrl;
  String? notes;

  Prescription({
    required this.id,
    this.imageUrl,
    this.notes,
  });

  Prescription copyWith({
    String? id,
    String? imageUrl,
    String? notes,
  }) =>
      Prescription(
        id: id ?? this.id,
        imageUrl: imageUrl ?? this.imageUrl,
        notes: notes ?? this.notes,
      );

  factory Prescription.fromJson(String str) =>
      Prescription.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Prescription.fromMap(Map<String, dynamic> json) => Prescription(
        id: json["id"],
        imageUrl: json["image_url"],
        notes: json["notes"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "image_url": imageUrl,
        "notes": notes,
      };
}

class Frequency {
  String id;
  String? type;
  Weekly? weekly;
  Monthly? monthly;
  Yearly? yearly;

  Frequency({
    required this.id,
    this.type,
    this.weekly,
    this.monthly,
    this.yearly,
  });

  Frequency copyWith({
    String? id,
    String? type,
    Weekly? weekly,
    Monthly? monthly,
    Yearly? yearly,
  }) =>
      Frequency(
        id: id ?? this.id,
        type: type ?? this.type,
        weekly: weekly ?? this.weekly,
        monthly: monthly ?? this.monthly,
        yearly: yearly ?? this.yearly,
      );

  factory Frequency.fromJson(String str) => Frequency.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Frequency.fromMap(Map<String, dynamic> json) => Frequency(
        id: json["id"],
        type: json["type"],
        weekly: json["weekly"] == null ? null : Weekly.fromMap(json["weekly"]),
        monthly:
            json["monthly"] == null ? null : Monthly.fromMap(json["monthly"]),
        yearly: json["yearly"] == null ? null : Yearly.fromMap(json["yearly"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type,
        "weekly": weekly?.toMap(),
        "monthly": monthly?.toMap(),
        "yearly": yearly?.toMap(),
      };
}

class Monthly {
  List<int>? dates;

  Monthly({
    this.dates,
  });

  Monthly copyWith({
    List<int>? dates,
  }) =>
      Monthly(
        dates: dates ?? this.dates,
      );

  factory Monthly.fromJson(String str) => Monthly.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Monthly.fromMap(Map<String, dynamic> json) => Monthly(
        dates: json["dates"] == null
            ? []
            : List<int>.from(json["dates"]!.map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "dates": dates == null ? [] : List<dynamic>.from(dates!.map((x) => x)),
      };
}

class Weekly {
  List<String>? days;

  Weekly({
    this.days,
  });

  Weekly copyWith({
    List<String>? days,
  }) =>
      Weekly(
        days: days ?? this.days,
      );

  factory Weekly.fromJson(String str) => Weekly.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Weekly.fromMap(Map<String, dynamic> json) => Weekly(
        days: json["days"] == null
            ? []
            : List<String>.from(json["days"]!.map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "days": days == null ? [] : List<dynamic>.from(days!.map((x) => x)),
      };
}

class Yearly {
  List<String>? dates;

  Yearly({
    this.dates,
  });

  Yearly copyWith({
    List<String>? dates,
  }) =>
      Yearly(
        dates: dates ?? this.dates,
      );

  factory Yearly.fromJson(String str) => Yearly.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Yearly.fromMap(Map<String, dynamic> json) => Yearly(
        dates: json["dates"] == null
            ? []
            : List<String>.from(json["dates"]!.map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "dates": dates == null ? [] : List<dynamic>.from(dates!.map((x) => x)),
      };
}
