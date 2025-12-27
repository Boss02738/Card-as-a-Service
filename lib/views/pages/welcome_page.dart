import 'package:flutter/material.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class Welcome_Page extends StatelessWidget {
  const Welcome_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GradientHeader(),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image.asset('assets/images/novapay_logo.png'),
            ),
          ),
        ],
      ),
    );
  }
}
