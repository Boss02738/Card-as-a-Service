import 'dart:convert';
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
    
    final dynamic args = Get.arguments; // ข้อมูลที่ส่งมาจากหน้า Slider

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            // 🚩 เมื่อหน้าเต็มจอโหลดเสร็จ ให้สั่ง JavaScript ทำงาน
            if (args != null && args['promotionId'] != null) {
              String promoId = args['promotionId'].toString();
              
              // สคริปต์นี้จะพยายามหาข้อความหรือ ID ที่ตรงกันในหน้าเว็บแล้วสั่งคลิกให้
              String script = """
                (function() {
                  var targetId = '$promoId';
                  var elements = document.querySelectorAll('button, a, .promo-item, div');
                  for (var i = 0; i < elements.length; i++) {
                    // ค้นหา Element ที่มี ID หรือเนื้อหาตรงกับโปรโมชั่นที่เลือก
                    if (elements[i].innerText.includes(targetId) || elements[i].outerHTML.includes(targetId)) {
                      elements[i].click();
                      break;
                    }
                  }
                })();
              """;
              controller.runJavaScript(script);
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            if (data['type'] == 'APPLY_DEBIT_CARD') {
              Get.toNamed('/type_cards', arguments: data); 
            }
          } catch (e) {
            // debugPrint("❌ Error: $e");
          }
        },
      )
      ..loadRequest(Uri.parse('http://10.82.241.88:5174/promotions'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรโมชั่น', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF264FAD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(), // ปิดหน้าเต็มเพื่อกลับไปหน้าหลัก
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}