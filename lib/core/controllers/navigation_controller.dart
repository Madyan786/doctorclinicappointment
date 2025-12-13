import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController get to => Get.find<NavigationController>();
  
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void goToHome() => changePage(0);
  void goToProfile() => changePage(1);
  void goToSettings() => changePage(2);
  void goToAppointments() => changePage(3);
  void goToDoctors() => changePage(4);
}
