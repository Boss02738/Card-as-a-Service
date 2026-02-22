import 'package:get/get.dart';
import 'package:my_app/module/controller/main_tab_controller.dart';

class MainTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainTabController(), permanent: true);
  }
}
