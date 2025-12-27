import 'package:flutter/material.dart';

class  buttonStyle {
  static final ButtonStyle buttonstyle = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 23, 51, 123),
    minimumSize: const Size(250, 45),

    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
