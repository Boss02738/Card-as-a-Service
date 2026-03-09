import 'dart:io';
import 'dart:math'; // เพิ่มสำหรับสุ่ม Nonce
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as get_x;
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/integrity_service.dart'; // Import service ที่คุณสร้างไว้

class ApiService {
  late Dio _dio;
  final storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  // pinning
  // 1. ใส่ค่า SHA-256 Fingerprint ของ Server คุณที่นี่
  final String _trustedFingerprint =
      "9A:1C:C2:76:08:E9:36:8D:EA:2C:C4:BB:9D:EC:46:22:89:6E:63:8C:EC:FB:12:FE:AC:AE:C5:2D:EA:B8:68:19";

  ApiService() {
    _dio = _createDioInstance(); // สร้าง instance หลัก
    _setupInterceptors(); // ตั้งค่า Interceptor
  }

  // ฟังก์ชันรวมศูนย์สำหรับสร้าง Dio พร้อม SSL Pinning
  Dio _createDioInstance() {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
            final serverFingerprint = _formatFingerprint(
              sha256.convert(cert.der).bytes,
            );
            return serverFingerprint ==
                _trustedFingerprint.toUpperCase().replaceAll(" ", "");
          };
      return client;
    };
    return dio;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // --- ส่วนเดิม: จัดการ Access Token ---
          String? token = await storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final integrityPaths = [
            ApiConstants.login,
            ApiConstants.refCode,
            ApiConstants.register,
            ApiConstants.changedevice,
            ApiConstants.forgetPassword,
          ];

          bool needsIntegrity = integrityPaths.any(
            (path) => options.path.contains(path),
          );

          // ภายใน onRequest ของ ApiService
          // ใน ApiService.dart ส่วน onRequest
          if (needsIntegrity) {
            try {
              // กำหนดค่าเริ่มต้นเป็นค่าว่างตามที่ BE แนะนำ
              String finalToken = "";
              String finalNonce = _generateRandomString(16);

              // พยายามขอ Token จริง (ถ้าได้ก็เอามาใช้ ถ้าไม่ได้หรือ Error ก็จะใช้ค่าว่างด้านบน)
              try {
                String? integrityToken =
                    await IntegrityService.requestToken(finalNonce).timeout(
                      const Duration(seconds: 20),
                    ); // ลด timeout ลงเพื่อไม่ให้หน้าจอรอนาน

                if (integrityToken != null) {
                  finalToken = integrityToken;
                  print("🔑 [Integrity] ได้ Token จริงมาใช้งาน");
                }
              } catch (e) {
                print(
                  "⚠️ [Integrity] ขอ Token จริงไม่สำเร็จ (ใช้ค่าว่างแทนตามที่ BE ยอมรับ): $e",
                );
              }

              // ✅ บังคับแนบ Header เสมอ (ถึงแม้ finalToken จะเป็นค่าว่าง "")
              options.headers['Novapay-App-Integrity-Token'] = finalToken;
              options.headers['Novapay-App-Nonce'] = finalNonce;

              print(
                " [Integrity Header] Attached: Token='$finalToken', Nonce='$finalNonce'",
              );
            } catch (e) {
              print(" Integrity Interceptor Error: $e");
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            if (e.requestOptions.path.contains(ApiConstants.login)) {
              return handler.next(e);
            }

            String? refreshToken = await storage.read(key: 'refreshToken');

            if (refreshToken != null && !_isRefreshing) {
              _isRefreshing = true;
              try {
                final refreshDio = _createDioInstance();

                final response = await refreshDio.post(
                  ApiConstants.refreshToken,
                  data: {'refreshToken': refreshToken},
                );

                if (response.statusCode == 200) {
                  String newAccess = response.data['token'];
                  String newRefresh = response.data['refreshToken'];

                  await storage.write(key: 'accessToken', value: newAccess);
                  await storage.write(key: 'refreshToken', value: newRefresh);

                  _isRefreshing = false;

                  e.requestOptions.headers['Authorization'] =
                      'Bearer $newAccess';
                  final retryResponse = await _dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (err) {
                _isRefreshing = false;
                await storage.delete(key: 'accessToken');
                await storage.delete(key: 'refreshToken');
                get_x.Get.offAllNamed('/login-pin');
                return handler.next(e);
              }
            } else if (refreshToken == null) {
              get_x.Get.offAllNamed('/login-pin');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Helper สำหรับสร้าง Nonce
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
    );
  }

  // Helper สำหรับแปลงพวง Bytes เป็น String Fingerprint
  String _formatFingerprint(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  Dio get instance => _dio;
}
