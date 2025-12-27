import 'package:get/get.dart';

class HeaderTextController extends GetxController {
  var title = ''.obs;
  var subtitle = ''.obs;

  void setHeaderText(String newTitle, String newSubtitle) {
    title.value = newTitle;
    subtitle.value = newSubtitle;
  }
}