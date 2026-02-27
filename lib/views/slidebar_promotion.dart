import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:my_app/views/promotion.dart';

class PromoSliderWebView extends StatefulWidget {
  const PromoSliderWebView({super.key});

  @override
  State<PromoSliderWebView> createState() => _PromoSliderWebViewState();
}

class _PromoSliderWebViewState extends State<PromoSliderWebView> {
  late final WebViewController _controller;

  final String pwaUrl = 'http://10.82.241.88:5174/?mode=webview';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);

            // ✅ อนุญาตเฉพาะหน้า slider
            final isSliderHome =
                uri.queryParameters['mode'] == 'webview';

            if (!isSliderHome) {
              // debugPrint("🚀 Promo Click → Fullscreen: ${request.url}");

              Get.to(
                () => const PromotionPage(),
                arguments: {'promotionUrl': request.url},
                transition: Transition.rightToLeft,
              );

              return NavigationDecision.prevent; // 🛑 ห้าม WebView โหลด
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);

            // debugPrint("📩 JS Message → $data");

            Get.to(
              () => const PromotionPage(),
              arguments: data,
              transition: Transition.rightToLeft,
            );
          } catch (e) {
            // debugPrint('❌ JS Parse Error: $e');
          }
        },
      )
      ..loadRequest(Uri.parse(pwaUrl));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.h,
      width: double.infinity,
      child: WebViewWidget(controller: _controller),
    );
  }
}