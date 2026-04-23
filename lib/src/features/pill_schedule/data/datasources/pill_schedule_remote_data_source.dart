import "package:dio/dio.dart";
import "package:jbl_pills_reminder_app/src/api/apis.dart";
import "../models/pill_schedule_model.dart";

abstract class PillScheduleRemoteDataSource {
  Future<void> createPillSchedule(PillScheduleModel schedule);
  Future<void> updatePillSchedule(int id, PillScheduleModel schedule);
  Future<List<PillScheduleModel>> getAllPillSchedules();
  Future<PillScheduleModel> getPillScheduleById(int id);
  Future<void> deletePillSchedule(int id);
}

class PillScheduleRemoteDataSourceImpl implements PillScheduleRemoteDataSource {
  final Dio dio;

  PillScheduleRemoteDataSourceImpl(this.dio);

  @override
  Future<void> createPillSchedule(PillScheduleModel schedule) async {
    try {
      await dio.post(
        pillSchedulesAPI,
        data: schedule.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePillSchedule(int id, PillScheduleModel schedule) async {
    try {
      await dio.patch(
        "$pillSchedulesAPI/$id",
        data: schedule.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PillScheduleModel>> getAllPillSchedules() async {
    try {
      final response = await dio.get(pillSchedulesAPI);
      final rawData = response.data;

      List dataList;
      if (rawData is Map) {
        final data = rawData["data"];
        if (data is Map && data["data"] is List) {
          dataList = data["data"];
        } else if (data is List) {
          dataList = data;
        } else {
          dataList = [];
        }
      } else if (rawData is List) {
        dataList = rawData;
      } else {
        dataList = [];
      }

      return dataList.map((e) => PillScheduleModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PillScheduleModel> getPillScheduleById(int id) async {
    try {
      final response = await dio.get("$pillSchedulesAPI/$id");
      final rawData = response.data;

      dynamic itemData;
      if (rawData is Map) {
        final data = rawData["data"];
        if (data is Map && data["data"] != null) {
          itemData = data["data"];
        } else {
          itemData = data ?? rawData;
        }
      } else {
        itemData = rawData;
      }

      return PillScheduleModel.fromJson(itemData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePillSchedule(int id) async {
    try {
      // Postman "Delete One" shows host/api/v1/pill-schedules but title says Delete One.
      // Usually it's /id or id in body. I'll use /id as it's more standard for REST.
      await dio.delete("$pillSchedulesAPI/$id");
    } catch (e) {
      rethrow;
    }
  }
}
