import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D56BB), // 100%
            // Color.fromARGB(127, 45, 85, 187), // 70%
            Color(0xB32D55BB), // 70%
          ],
        ),
      ),
    );
  }
}
