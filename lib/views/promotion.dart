import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PromotionPage extends StatefulWidget {
  const PromotionPage({super.key});

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    // สร้างตัวควบคุม WebView และใส่ลิงก์โปรโมชั่น
    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      ) // อนุญาตให้รัน JavaScript ในหน้าเว็บ
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // คุณสามารถเพิ่ม Loading bar ตรงนี้ได้
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse('https://eloquent-llama-a90055.netlify.app/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรโมชั่น',style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
        backgroundColor: const Color(0xFF264FAD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 255, 255, 255), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
