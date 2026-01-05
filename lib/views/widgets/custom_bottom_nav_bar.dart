import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF264FAD),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'บัญชีของฉัน'),
            BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'บัตรของฉัน'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ตั้งค่า'),
          ],
        ),
      ),
    );
  }
}