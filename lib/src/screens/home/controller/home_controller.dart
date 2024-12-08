import 'package:get/get.dart';

class HomeController extends GetxController {
  Rx<DateTime> selectedDay = DateTime.now().obs;
  RxList<int> listOfMedications = RxList<int>([]);
  RxList<int> listOfMedicines = RxList<int>([]);
}
