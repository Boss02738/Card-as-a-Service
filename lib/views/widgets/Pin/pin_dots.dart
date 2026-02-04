// widgets/pin/pin_dots.dart
import 'package:flutter/material.dart';

class PinDots extends StatelessWidget {
  final int length;
  final int maxLength;

  const PinDots({
    super.key,
    required this.length,
    this.maxLength = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final filled = index < length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent, width: 2),
            color: filled ? Colors.blueAccent : Colors.transparent,
          ),
        );
      }),
    );
  }
}
