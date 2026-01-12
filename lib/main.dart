import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prevent_screenshot/disablescreenshot.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_app/views/pages/Register/enter_phone_page.dart';
import 'package:my_app/views/pages/Register/face_verify.dart';
import 'package:my_app/views/pages/Create_cards/card_details.dart';
import 'package:my_app/views/pages/account_page.dart';
import 'package:my_app/views/pages/cards/change_limit_card.dart';
import 'package:my_app/views/pages/cards/sensitivedata.dart';
import 'package:my_app/views/pages/home_page.dart';
import 'package:my_app/views/pages/Register/idcard_verify.dart';
import 'package:my_app/views/pages/Register/info.dart';
import 'package:my_app/views/pages/Register/success_register_page.dart';
import 'package:my_app/views/pages/cards/my_card_detail.dart';
import 'package:my_app/views/pages/cards/my_card_page.dart';
import 'package:my_app/views/pages/physical/address.dart';
import 'package:my_app/views/pages/pin_login_page.dart';
import 'package:my_app/views/pages/Register/welcome_page.dart';
import 'package:my_app/views/pages/Register/confirm_otp.dart';
import 'package:my_app/views/pages/Create_cards/pin_verify_page.dart';
import 'package:my_app/views/pages/Create_cards/success_page.dart';
import 'package:my_app/views/pages/Create_cards/type_cards.dart';
import 'package:my_app/views/pages/Create_cards/card_confirm_page.dart';
import 'package:my_app/views/pages/profile.dart';
import 'package:my_app/views/pages/setting_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NovaPayApp());
}

class NovaPayApp extends StatefulWidget {
  const NovaPayApp({super.key});
  @override
  State<NovaPayApp> createState() => _NovaPayAppState();
}

class _NovaPayAppState extends State<NovaPayApp> {
  // ย้าย Logic การกัน Screenshot มาไว้ที่นี่ตามเดิม
  final _flutterPreventScreenshot = FlutterPreventScreenshot.instance;

  @override
  void initState() {
    super.initState();
    _flutterPreventScreenshot.screenshotOff();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/profile',
      getPages: [
        //Register
        GetPage(name: '/', page: () => const Welcome_Page()),
        GetPage(name: '/enter-phone', page: () => const EnterPhonePage()),
        GetPage(name: '/success', page: () => const SuccessRegisterPage()),
        GetPage(name: '/confirm-otp', page: () => const Confirm_otp()),
        //Login & Home
        GetPage(name: '/login-pin', page: () => const PinLoginPage()),
        GetPage(name: "/home", page: () => const HomePage()),
        GetPage(name: "/account", page: () => const AccountPage()),
        //Card
        GetPage(name: "/my_cards", page: () => const MyCardPage()),
        GetPage(name: "/my_card_detail", page: () => MyCardDetail()),
        GetPage(
          name: "/change_limit_card",
          page: () => const ChangeLimitCard(),
        ),
        GetPage(name: "/sensitive", page: () => const SensitiveDataPage()),

        //creaate_card
        GetPage(name: "/type_cards", page: () => const Type_Cards()),
        GetPage(name: "/card_detail", page: () => const Card_Detail()),
        GetPage(name: "/card_confirm", page: () => const Card_Confirm_Page()),
        GetPage(name: "/pin_verify_page", page: () => const PinVerifyPage()),
        GetPage(name: "/success_createcard", page: () => const SuccessPaga()),
        //Physical card
        GetPage(name: "/adress", page: () => const Address()),
        //Setting
        GetPage(name: "/setting", page: () => const SettingPage()),
        GetPage(name: "/profile", page: () => const Profile()),
      ],
    );
  }
}
