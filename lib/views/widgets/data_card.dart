import 'package:flutter/material.dart';

class DataCard extends StatelessWidget {
  final Widget child;
  const DataCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: child,
    );
  }
}
