import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';

class AddNewMedicationController extends GetxController {
  RxList<MedicationModel> medications = <MedicationModel>[].obs;
}
