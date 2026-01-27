class ApiConstants {
  // ใช้ IP ของเครื่อง Backend
  // static const String baseUrl = "http://192.168.250.35:8084";
  // static const String baseUrlCore = "http://10.82.241.156:8080";

  static const String baseUrl = "http://10.82.241.238:8084";

  //Register
  static const String refcode = "/api/v1/mobile/auth/request-otp";
  static const String register = "/api/v1/mobile/auth/register";
  static const String changedevice = "/api/v1/mobile/auth/change-device";

  //Login & Home
  static const String login = "/api/v1/mobile/auth/login";
  static const String account = "/api/v1/mobile/feature/home-profile";

  //Card
  //Create_card
  static const String typecards = "/api/v1/mobile/feature/card-products";
  static const String createcard = "/api/v1/mobile/feature/create-virtual-card";

  // My Cards
  static const String mycards = "/api/v1/mobile/feature/my-cards";
  
  static const String freeze = "/api/v1/mobile/feature/card/freeze";
  static const String unfreeze ="/api/v1/mobile/feature/card/unfreeze";
  static const String limitcard = "/api/v1/mobile/feature/card/limit";
  static const String sensitive = "/api/v1/mobile/feature/card/sensitive";
  static const String requestphysicalcard ="/api/v1/mobile/feature/card/physical";
  static const String activatecard = "/api/v1/mobile/feature/card/activate";

  static const String cardDetail = "/api/v1/mobile/feature/card/detail";
  //pin
  static const String changePassword = "/api/v1/mobile/feature/change-pin";
  static const String forgetPassword = "/api/v1/mobile/auth/forget-pin";
}
