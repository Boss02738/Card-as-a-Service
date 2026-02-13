class ApiConstants {
  // ใช้ IP ของเครื่อง Backend
  static const String baseUrl = "http://192.168.250.35:8084";
  // static const String baseUrlCore = "http://10.82.241.156:8080";

  // static const String baseUrl = "http://10.82.241.238:8084";

  static const String auth = "/api/v1/mobile/auth";
  static const String feature = "/api/v1/mobile/feature";
  //Register
  // static const String REF_CODE = "${auth}/request-otp";
  static const String refCode = "${auth}/request-otp";
  static const String register = "${auth}/register";
  static const String changedevice = "${auth}/change-device";
  //Login & Home
  static const String login = "${auth}/login";
  static const String account = "${feature}/home-profile";
  static const String refreshToken = "${auth}/refresh-token";
  //Card
  //Create_card
  static const String typecards = "${feature}/card-products";
  static const String createcard = "${feature}/create-virtual-card";

  // My Cards
  static const String mycards = "${feature}/my-cards";
  static const String freeze = "${feature}/card/freeze";
  static const String unfreeze ="${feature}/card/unfreeze";
  static const String limitcard = "${feature}/card/limit";
  static const String sensitive = "${feature}/card/sensitive";

  static const String cardTraking = "${feature}/card/tracking";
  static const String requestphysicalcard ="${feature}/card/physical";
  static const String activatecard = "${feature}/card/activate";

  static const String cardDetail = "${feature}/card/detail";
  //pin
  static const String changePassword = "$feature/change-pin";
  static const String forgetPassword = "$auth/forget-pin";
}
