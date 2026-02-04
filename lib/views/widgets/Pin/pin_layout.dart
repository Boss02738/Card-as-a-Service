// widgets/pin/pin_layout.dart
import 'package:flutter/material.dart';
import 'package:my_app/views/widgets/brand_logo.dart';

class PinLayout extends StatelessWidget {
  final String title;
  final Widget dots;
  final Widget keypad;
  final bool isLoading;

  const PinLayout({
    super.key,
    required this.title,
    required this.dots,
    required this.keypad,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const BrandLogo(),
              const SizedBox(height: 40),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              dots,
              const Spacer(),
              keypad,
              const SizedBox(height: 40),
            ],
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
