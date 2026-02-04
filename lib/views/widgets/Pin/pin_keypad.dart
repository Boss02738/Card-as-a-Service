// widgets/pin/pin_keypad.dart
import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  final void Function(int) onNumber;
  final VoidCallback onDelete;
  final Widget leftWidget;

  const PinKeypad({
    super.key,
    required this.onNumber,
    required this.onDelete,
    this.leftWidget = const SizedBox(width: 80),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map((n) => _key(n.toString(), () => onNumber(n)))
                  .toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              leftWidget,
              _key('0', () => onNumber(0)),
              IconButton(
                icon: const Icon(Icons.backspace_outlined, size: 28),
                onPressed: onDelete,
                constraints: const BoxConstraints(minWidth: 80),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _key(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
