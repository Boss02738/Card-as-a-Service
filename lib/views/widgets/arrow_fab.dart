import 'package:flutter/material.dart';

class ArrowFab extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const ArrowFab({
    super.key,
    required this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: const Color.fromARGB(255, 113, 167, 33),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: const Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ),
    );
  }
}
