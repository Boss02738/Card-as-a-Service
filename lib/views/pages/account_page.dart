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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white, // ส่วนล่างเป็นสีขาว
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF3B5BDB), Color(0xFF162E7A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                homeController.fullNameTh.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    homeController.accountType.value,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    homeController.accountNumber.value,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildRow(
                                'ชื่อบัญชี',
                                homeController.fullNameTh.value,
                              ),
                              _buildRow(
                                'ประเภทบัญชี',
                                homeController.accountType.value,
                              ),
                              _buildRow('อัตราดอกเบี้ย (%)', '0.25'),
                              _buildRow(
                                'วันที่เปิดบัญชี',
                                homeController.createdAt.value,
                              ),
                              const SizedBox(height: 20),
                              _buildRow(
                                'ยอดเงินคงเหลือ',
                                homeController.balance.value
                                    .toStringAsFixed(2)
                                    .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]},',
                                    ),
                                isBoldValue: true,
                              ),
                              _buildRow(
                                'ยอดเงินที่ใช้ได้',
                                homeController.balance.value
                                    .toStringAsFixed(2)
                                    .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]},',
                                    ),
                                isBoldValue: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  } else if (index == 3) {
                    Get.toNamed('/setting');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 77, 77, 77),
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ??  Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
