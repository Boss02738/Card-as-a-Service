import 'package:get/get.dart';
import 'package:my_app/module/controller/mainTab_Controller%20.dart';

class MainTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainTabController(), permanent: true);
  }
}
