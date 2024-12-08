import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';

class HomeController extends GetxController {
  Rx<DateTime> selectedDay = DateTime.now().obs;
  RxList<MedicationModel> listOfTodaysMedications = RxList<MedicationModel>([]);
  RxList<MedicationModel> listOfAllMedications = RxList<MedicationModel>([]);
}
