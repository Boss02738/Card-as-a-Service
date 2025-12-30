import 'package:flutter/material.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [
             Text('หน้าเเรก Homepage'),
              GradientHeader()
          ],
        ),
      ),
    );
  }
}