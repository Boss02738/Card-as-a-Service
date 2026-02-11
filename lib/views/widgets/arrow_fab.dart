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
        // เปลี่ยนสีตามสถานะ enabled: ถ้ายังไม่กดให้เป็นสีเทา (Grey), ถ้ากดแล้วให้เป็นสีเขียว
        color: enabled 
            ? const Color.fromARGB(255, 113, 167, 33) // สีเขียวตอนใช้งานได้
            : Colors.grey[300], // สีเทาตอนยังไม่ได้ติ๊ก Checkbox
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Icon(
            Icons.arrow_forward, 
            color: enabled ? Colors.white : Colors.grey[500] // เปลี่ยนสีไอคอนด้วย
          ),
        ),
      ),
    );
  }
}