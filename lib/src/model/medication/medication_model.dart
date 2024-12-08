import 'package:jbl_pill_reminder_app/src/model/user/user_model.dart';
import 'dart:convert';

class MedicationModel {
  User user;
  List<Medication> medications;

  MedicationModel({
    required this.user,
    required this.medications,
  });

  MedicationModel copyWith({
    User? user,
    List<Medication>? medications,
  }) =>
      MedicationModel(
        user: user ?? this.user,
        medications: medications ?? this.medications,
      );

  factory MedicationModel.fromJson(String str) =>
      MedicationModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MedicationModel.fromMap(Map<String, dynamic> json) => MedicationModel(
        user: User.fromMap(json["user"]),
        medications: List<Medication>.from(
            json["medications"].map((x) => Medication.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "user": user.toMap(),
        "medications": List<dynamic>.from(medications.map((x) => x.toMap())),
      };
}

class Medication {
  String id;
  String title;
  List<Medicine> medicines;
  Schedule schedule;
  Prescription prescription;

  Medication({
    required this.id,
    required this.title,
    required this.medicines,
    required this.schedule,
    required this.prescription,
  });

  Medication copyWith({
    String? id,
    String? title,
    List<Medicine>? medicines,
    Schedule? schedule,
    Prescription? prescription,
  }) =>
      Medication(
        id: id ?? this.id,
        title: title ?? this.title,
        medicines: medicines ?? this.medicines,
        schedule: schedule ?? this.schedule,
        prescription: prescription ?? this.prescription,
      );

  factory Medication.fromJson(String str) =>
      Medication.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Medication.fromMap(Map<String, dynamic> json) => Medication(
        id: json["id"],
        title: json["title"],
        medicines: List<Medicine>.from(
            json["medicines"].map((x) => Medicine.fromMap(x))),
        schedule: Schedule.fromMap(json["schedule"]),
        prescription: Prescription.fromMap(json["prescription"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "medicines": List<dynamic>.from(medicines.map((x) => x.toMap())),
        "schedule": schedule.toMap(),
        "prescription": prescription.toMap(),
      };
}

class Medicine {
  String id;
  String name;
  String type;
  String imageUrl;
  String color;
  String notes;

  Medicine({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.color,
    required this.notes,
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
  String imageUrl;
  String notes;

  Prescription({
    required this.imageUrl,
    required this.notes,
  });

  Prescription copyWith({
    String? imageUrl,
    String? notes,
  }) =>
      Prescription(
        imageUrl: imageUrl ?? this.imageUrl,
        notes: notes ?? this.notes,
      );

  factory Prescription.fromJson(String str) =>
      Prescription.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Prescription.fromMap(Map<String, dynamic> json) => Prescription(
        imageUrl: json["image_url"],
        notes: json["notes"],
      );

  Map<String, dynamic> toMap() => {
        "image_url": imageUrl,
        "notes": notes,
      };
}

class Schedule {
  String startDate;
  String endDate;
  Frequency frequency;
  List<String> times;

  Schedule({
    required this.startDate,
    required this.endDate,
    required this.frequency,
    required this.times,
  });

  Schedule copyWith({
    String? startDate,
    String? endDate,
    Frequency? frequency,
    List<String>? times,
  }) =>
      Schedule(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        frequency: frequency ?? this.frequency,
        times: times ?? this.times,
      );

  factory Schedule.fromJson(String str) => Schedule.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Schedule.fromMap(Map<String, dynamic> json) => Schedule(
        startDate: json["start_date"],
        endDate: json["end_date"],
        frequency: Frequency.fromMap(json["frequency"]),
        times: List<String>.from(json["times"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "start_date": startDate,
        "end_date": endDate,
        "frequency": frequency.toMap(),
        "times": List<dynamic>.from(times.map((x) => x)),
      };
}

class Frequency {
  String type;
  Weekly weekly;
  Monthly monthly;
  Yearly yearly;

  Frequency({
    required this.type,
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  Frequency copyWith({
    String? type,
    Weekly? weekly,
    Monthly? monthly,
    Yearly? yearly,
  }) =>
      Frequency(
        type: type ?? this.type,
        weekly: weekly ?? this.weekly,
        monthly: monthly ?? this.monthly,
        yearly: yearly ?? this.yearly,
      );

  factory Frequency.fromJson(String str) => Frequency.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Frequency.fromMap(Map<String, dynamic> json) => Frequency(
        type: json["type"],
        weekly: Weekly.fromMap(json["weekly"]),
        monthly: Monthly.fromMap(json["monthly"]),
        yearly: Yearly.fromMap(json["yearly"]),
      );

  Map<String, dynamic> toMap() => {
        "type": type,
        "weekly": weekly.toMap(),
        "monthly": monthly.toMap(),
        "yearly": yearly.toMap(),
      };
}

class Monthly {
  List<int> dates;

  Monthly({
    required this.dates,
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
        dates: List<int>.from(json["dates"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "dates": List<dynamic>.from(dates.map((x) => x)),
      };
}

class Weekly {
  List<String> days;

  Weekly({
    required this.days,
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
        days: List<String>.from(json["days"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "days": List<dynamic>.from(days.map((x) => x)),
      };
}

class Yearly {
  List<String> dates;

  Yearly({
    required this.dates,
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
        dates: List<String>.from(json["dates"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "dates": List<dynamic>.from(dates.map((x) => x)),
      };
}
