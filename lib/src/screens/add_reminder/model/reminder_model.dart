import "dart:convert";

import "package:jbl_pills_reminder_app/src/resources/medicine_list.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/schedule_model.dart";

class ReminderModel {
  String id;
  String? description;
  MedicineModel? medicine;
  ScheduleModel? schedule;
  String? quantity;
  ReminderType? reminderType;

  ReminderModel({
    required this.id,
    this.description,
    this.medicine,
    this.schedule,
    this.quantity,
    this.reminderType,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    MedicineModel? medicine,
    ScheduleModel? schedule,
    String? quantity,
    ReminderType? reminderType,
  }) =>
      ReminderModel(
        id: id ?? this.id,
        description: description ?? this.description,
        medicine: medicine ?? this.medicine,
        schedule: schedule ?? this.schedule,
        quantity: quantity ?? this.quantity,
        reminderType: reminderType ?? this.reminderType,
      );

  factory ReminderModel.fromJson(String str) =>
      ReminderModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ReminderModel.fromMap(Map<String, dynamic> json) => ReminderModel(
        id: json["id"],
        description: json["description"],
        medicine: json["medicine"] == null
            ? null
            : MedicineModel.fromMap(json["medicine"]),
        schedule: json["schedule"] == null
            ? null
            : ScheduleModel.fromMap(json["schedule"]),
        quantity: json["quantity"],
        reminderType: ReminderType.values.firstWhere(
          (element) => element.name == json["reminder_type"],
        ),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "description": description,
        "medicine": medicine?.toMap(),
        "schedule": schedule?.toMap(),
        "quantity": quantity,
        "reminder_type": reminderType?.name,
      };
}

enum ReminderType { alarm, notification }
