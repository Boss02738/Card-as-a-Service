import 'package:flutter/material.dart';
import 'package:my_app/views/widgets/brand_logo.dart';

class Buildheader extends StatelessWidget {
  const Buildheader({super.key});

  @override
  Widget build(BuildContext context) {
      return Stack(
    alignment: Alignment.center,
    children: [
      const Center(child: BrandLogo()),
      Positioned(
        left: 15,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
    ],
  );
  }
}
