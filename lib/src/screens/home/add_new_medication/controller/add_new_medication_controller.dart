import 'dart:math';

import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';

class AddNewMedicationController extends GetxController {
  Rx<MedicationModel> medications =
      MedicationModel(id: (Random().nextInt(100000000) + 100000000).toString())
          .obs;
}
