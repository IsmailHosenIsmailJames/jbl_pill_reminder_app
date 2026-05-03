import "package:dio/dio.dart";
import "../../../../api/apis.dart";
import "../models/reminder_model.dart";

abstract class ReminderRemoteDataSource {
  Future<void> createReminder(Map<String, dynamic> data);
  Future<List<ReminderModel>> getAllReminders({String? status, bool? isNextReminders});
  Future<ReminderModel> getReminderById(int id);
  Future<void> updateReminder(int id, Map<String, dynamic> data);
  Future<void> deleteReminder(int id);
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final Dio dio;

  ReminderRemoteDataSourceImpl(this.dio);

  @override
  Future<void> createReminder(Map<String, dynamic> data) async {
    try {
      await dio.post(remindersAPI, data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ReminderModel>> getAllReminders(
      {String? status, bool? isNextReminders}) async {
    try {
      final response = await dio.get(
        remindersAPI,
        queryParameters: {
          if (status != null) "status": status,
          if (isNextReminders != null) "isNextReminders": isNextReminders,
        },
      );
      final rawData = response.data;

      List dataList;
      if (rawData is Map) {
        final data = rawData["data"];
        if (data is List) {
          dataList = data;
        } else if (data is Map && data["data"] is List) {
          dataList = data["data"];
        } else {
          dataList = [];
        }
      } else if (rawData is List) {
        dataList = rawData;
      } else {
        dataList = [];
      }

      return dataList.map((e) => ReminderModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ReminderModel> getReminderById(int id) async {
    try {
      final response = await dio.get("$remindersAPI/$id");
      final rawData = response.data;

      dynamic itemData;
      if (rawData is Map) {
        itemData = rawData["data"] ?? rawData;
      } else {
        itemData = rawData;
      }

      return ReminderModel.fromJson(itemData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateReminder(int id, Map<String, dynamic> data) async {
    try {
      await dio.patch("$remindersAPI/$id", data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteReminder(int id) async {
    try {
      await dio.delete("$remindersAPI/$id");
    } catch (e) {
      rethrow;
    }
  }
}
