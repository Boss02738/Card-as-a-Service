import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/views/widgets/account_widget.dart';
import 'package:my_app/views/widgets/buildHeader.dart';
import 'package:my_app/views/widgets/custom_bottom_nav_bar.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final HomeController homeController = Get.put(HomeController());
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Buildheader(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: AccountWidget(),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomBottomNavBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });

                  if (index == 0) {
                    Get.toNamed('/home');
                  } else if (index == 2) {
                    Get.toNamed('/my_cards');
                  }
                  // }else if (index == 4) {
                  //   Get.toNamed('/settings');
                  // }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
