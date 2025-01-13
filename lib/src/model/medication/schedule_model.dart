import 'dart:convert';

class ScheduleModel {
  DateTime startDate = DateTime.now();
  DateTime? endDate;
  Frequency? frequency;
  List<TimeModel>? times;

  ScheduleModel({
    required this.startDate,
    this.endDate,
    this.frequency,
    this.times,
  });

  ScheduleModel copyWith({
    DateTime? startDate,
    DateTime? endDate,
    Frequency? frequency,
    List<TimeModel>? times,
    String? notes,
  }) =>
      ScheduleModel(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        frequency: frequency ?? this.frequency,
        times: times ?? this.times,
      );

  factory ScheduleModel.fromJson(String str) =>
      ScheduleModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ScheduleModel.fromMap(Map<String, dynamic> json) => ScheduleModel(
        startDate: json["start_date"] != null
            ? DateTime.parse(json["start_date"])
            : DateTime.now(),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        frequency: json["frequency"] == null
            ? null
            : Frequency.fromMap(json["frequency"]),
        times: json["times"] == null
            ? []
            : List<TimeModel>.from(
                json["times"]!.map((x) => TimeModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "start_date":
            "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date":
            "${endDate?.year.toString().padLeft(4, '0')}-${endDate?.month.toString().padLeft(2, '0')}-${endDate?.day.toString().padLeft(2, '0')}",
        "frequency": frequency?.toMap(),
        "times": times == null
            ? []
            : List<dynamic>.from(times!.map((x) => x.toMap())),
      };
}

class Frequency {
  String? type;
  Weekly? weekly;
  Monthly? monthly;
  Yearly? yearly;
  int? everyXDays;

  Frequency({
    this.type,
    this.weekly,
    this.monthly,
    this.yearly,
    this.everyXDays,
  });

  Frequency copyWith({
    String? type,
    Weekly? weekly,
    Monthly? monthly,
    Yearly? yearly,
    int? everyXDays,
  }) =>
      Frequency(
        type: type ?? this.type,
        weekly: weekly ?? this.weekly,
        monthly: monthly ?? this.monthly,
        yearly: yearly ?? this.yearly,
        everyXDays: everyXDays ?? this.everyXDays,
      );

  factory Frequency.fromJson(String str) => Frequency.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Frequency.fromMap(Map<String, dynamic> json) => Frequency(
        type: json["type"],
        weekly: json["weekly"] == null ? null : Weekly.fromMap(json["weekly"]),
        monthly:
            json["monthly"] == null ? null : Monthly.fromMap(json["monthly"]),
        yearly: json["yearly"] == null ? null : Yearly.fromMap(json["yearly"]),
        everyXDays: json["every_x_days"],
      );

  Map<String, dynamic> toMap() => {
        "type": type,
        "weekly": weekly?.toMap(),
        "monthly": monthly?.toMap(),
        "yearly": yearly?.toMap(),
        "every_x_days": everyXDays,
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
  List<DateTime>? dates;

  Yearly({
    this.dates,
  });

  Yearly copyWith({
    List<DateTime>? dates,
  }) =>
      Yearly(
        dates: dates ?? this.dates,
      );

  factory Yearly.fromJson(String str) => Yearly.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Yearly.fromMap(Map<String, dynamic> json) => Yearly(
        dates: json["dates"] == null
            ? []
            : List<DateTime>.from(json["dates"]!.map((x) => DateTime.parse(x))),
      );

  Map<String, dynamic> toMap() => {
        "dates": dates == null
            ? []
            : List<dynamic>.from(dates!.map((x) =>
                "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
      };
}

class TimeModel {
  String id;
  String? timeOnDay;
  String? clock;
  String? when;
  String? notes;

  TimeModel({
    required this.id,
    this.timeOnDay,
    this.clock,
    this.when,
    this.notes,
  });

  TimeModel copyWith({
    String? id,
    String? timeOnDay,
    String? clock,
    String? when,
    String? notes,
  }) =>
      TimeModel(
        id: id ?? this.id,
        timeOnDay: timeOnDay ?? this.timeOnDay,
        clock: clock ?? this.clock,
        when: when ?? this.when,
        notes: notes ?? this.notes,
      );

  factory TimeModel.fromJson(String str) => TimeModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TimeModel.fromMap(Map<String, dynamic> json) => TimeModel(
        id: json["id"],
        timeOnDay: json["time_on_day"],
        clock: json["clock"],
        when: json["when"],
        notes: json["notes"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "time_on_day": timeOnDay,
        "clock": clock,
        "when": when,
        "notes": notes,
      };
}
