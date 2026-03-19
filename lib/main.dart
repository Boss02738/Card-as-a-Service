import 'package:flutter/material.dart';
import 'package:flutter_prevent_screenshot/disablescreenshot.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_app/module/binding/main_tab_binding.dart';
import 'package:my_app/module/controller/header_text_controller.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/module/controller/main_tab_controller.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:my_app/views/pages/Register/change_device_page.dart';
import 'package:my_app/views/pages/Register/enter_phone_page.dart';
import 'package:my_app/views/pages/Register/face_verify.dart';
import 'package:my_app/views/pages/Create_cards/card_details.dart';
import 'package:my_app/views/pages/Register/pin_page.dart';
import 'package:my_app/views/pages/Register/user_selection_page.dart';
import 'package:my_app/views/pages/account_page.dart';
import 'package:my_app/views/pages/cards/activate_physical.dart';
import 'package:my_app/views/pages/cards/change_limit_card.dart';
import 'package:my_app/views/pages/cards/request_physicalcard.dart';
import 'package:my_app/views/pages/cards/sensitivedata.dart';
import 'package:my_app/views/pages/changepin_page.dart';
import 'package:my_app/views/pages/home_page.dart';
import 'package:my_app/views/pages/Register/idcard_verify.dart';
import 'package:my_app/views/pages/Register/info.dart';
import 'package:my_app/views/pages/Register/success_register_page.dart';
import 'package:my_app/views/pages/cards/my_card_detail.dart';
import 'package:my_app/views/pages/cards/my_card_page.dart';
import 'package:my_app/views/pages/physical/address.dart';
import 'package:my_app/views/pages/physical/setpin_physical.dart';
import 'package:my_app/views/pages/pin_login_page.dart';
import 'package:my_app/views/pages/Register/welcome_page.dart';
import 'package:my_app/views/pages/Register/confirm_otp.dart';
import 'package:my_app/views/pages/Create_cards/pin_verify_page.dart';
import 'package:my_app/views/pages/Create_cards/success_page.dart';
import 'package:my_app/views/pages/Create_cards/type_cards.dart';
import 'package:my_app/views/pages/Create_cards/card_confirm_page.dart';
import 'package:my_app/views/pages/profile.dart';
import 'package:my_app/views/pages/setting_page.dart';
import 'package:my_app/views/promotion.dart';
import 'package:my_app/views/slidebar_promotion.dart';
import 'package:my_app/views/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(NovaPayApp());
  });
}

class NovaPayApp extends StatefulWidget {
  NovaPayApp({super.key});
  final pages = [HomePage(), MyCardPage(), SettingTabPage()];
  @override
  State<NovaPayApp> createState() => _NovaPayAppState();
}

class _NovaPayAppState extends State<NovaPayApp> {
  final _flutterPreventScreenshot = FlutterPreventScreenshot.instance;

  @override 
  void initState() {
    super.initState();
    _flutterPreventScreenshot.screenshotOff();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
          debugShowCheckedModeBanner: false,
          initialRoute: '/', // เปลี่ยนเป็นหน้าแรกที่ต้องการ
          initialBinding: BindingsBuilder(() {
            // Get.lazyPut(() => PhonenumberController(), fenix: true);
            Get.lazyPut(() => HeaderTextController(), fenix: true);
            Get.lazyPut(() => HomeController(), fenix: true);
            Get.lazyPut(() => MyCardsController(), fenix: true);
          }),
          getPages: [
            GetPage(
              name: "/main",
              page: () => MainPage(),
              binding: MainTabBinding(),
            ),
            //Register
            GetPage(name: '/', page: () => const Welcome_Page()),
            GetPage(name: '/enter-phone', page: () => const EnterPhonePage()),
            GetPage(name: '/success', page: () => const SuccessRegisterPage()),
            GetPage(name: '/confirm-otp', page: () => const Confirm_otp()),
            GetPage(name: '/face_verify', page: () => const FaceVerify()),
            GetPage(name: '/pin_page', page: () => const PinPage()),
            //Login & Home
            GetPage(name: '/login-pin', page: () => const PinLoginPage()),
            GetPage(name: "/home", page: () => const HomePage()),
            GetPage(name: "/account", page: () => const AccountPage()),
            GetPage(name: "/main", page: () => MainPage()),
            //PWA
            GetPage(name: "/promotion", page: () => const PromotionPage()),
            GetPage(name: "/slide_promotion", page: () => const PromoSliderWebView()),
            //Card
            GetPage(name: "/my_cards", page: () => const MyCardPage()),
            GetPage(name: "/my_card_detail", page: () => const MyCardDetail()),
            GetPage(
              name: "/change_limit_card",
              page: () => const ChangeLimitCard(),
            ),
            GetPage(name: "/sensitive", page: () => const SensitiveDataPage()),
            //creaate_card
            GetPage(name: "/type_cards", page: () => const Type_Cards()),
            GetPage(name: "/card_detail", page: () => const Card_Detail()),
            GetPage(
              name: "/card_confirm",
              page: () => const Card_Confirm_Page(),
            ),
            GetPage(
              name: "/pin_verify_page",
              page: () => const PinVerifyPage(),
            ),
            GetPage(name: "/success_page", page: () => const SuccessPaga()),
            //Physical card
            GetPage(name: "/address_input", page: () => const Address()),
            GetPage(
              name: "/requestPhysical",  
              page: () => const RequestPhysical(),
            ),
            GetPage(
              name: "/activate_physical",
              page: () => const ActivatePhysical(),
            ),
            GetPage(name: "/set_card_pin", page: () => const SetpinPhysical()),
            //Setting
            GetPage(name: "/setting", page: () => const SettingTabPage()),
            GetPage(name: "/profile", page: () => const Profile()),
            //pin
            GetPage(name: "/change_pin", page: () => const ChangePinPage()),
            GetPage(name: "/pin_page", page: () => const PinPage()),
            GetPage(
              name: '/user_selection',
              page: () => const UserSelectionPage(),
            ),
            GetPage(
              name: '/change_device',
              page: () => const ChangeDevicePage(),
            ),
            GetPage(name: '/idcard_verify', page: () => const IdcardVerify()),
          ],
        );  
      },
    );
  }
}

class MainPage extends StatelessWidget {
  MainPage({super.key});
  final controller = Get.find<MainTabController>();
  final pages = [HomePage(), AccountPage(), MyCardPage(), SettingTabPage()];
  
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}