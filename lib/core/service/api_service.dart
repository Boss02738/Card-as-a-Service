import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as get_x;
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/integrity_service.dart';

class ApiService {
  late Dio _dio;
  final storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  final String _trustedFingerprint = "07299C6033424B00ADD188B6B7951C09F66C7ABE8A3C6266911A65C96975E729";

  ApiService() {
    _dio = _createDioInstance();
    _setupInterceptors();
  }

  Dio _createDioInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl, 
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // คำนวณค่าจากใบเซอร์ที่ Server ส่งมาจริง ๆ
        final serverFingerprint = _formatFingerprint(
          sha256.convert(cert.der).bytes,
        );

        // 📝 [DEBUG SECTION] สั่ง Print ออกมาดูค่าจริง
        print("==================================================");
        print("🔍 [SSL PINNING CHECK]");
        print("🔗 Host: $host");
        print("🔑 SERVER ACTUAL FINGERPRINT: $serverFingerprint");
        print("📌 EXPECTED FINGERPRINT IN CODE: ${_trustedFingerprint.replaceAll(":", "").toUpperCase()}");
        print("==================================================");
        return true; 
      };
      return client;
    };
    return dio;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // จัดการ Access Token
          String? token = await storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // ตรวจสอบ Path ที่ต้องใช้ Play Integrity
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

          if (needsIntegrity) {
            try {
              String finalToken = "";
              String finalNonce = _generateRandomString(16);

              try {
                String? integrityToken = await IntegrityService.requestToken(finalNonce)
                    .timeout(const Duration(seconds: 5));

                if (integrityToken != null) {
                  finalToken = integrityToken;
                  print(" [Integrity] Token acquired successfully");
                }
              } catch (e) {
                print(" [Integrity] Error/Timeout: Using empty token as fallback");
              }

              options.headers['Novapay-App-Integrity-Token'] = finalToken;
              options.headers['Novapay-App-Nonce'] = finalNonce;
            } catch (e) {
              print(" Integrity Interceptor Error: $e");
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized และ Refresh Token
          if (e.response?.statusCode == 401) {
            if (e.requestOptions.path.contains(ApiConstants.login) ||
                e.requestOptions.path.contains(ApiConstants.verifyPin) ||
                e.requestOptions.path.contains(ApiConstants.activatecard)) {
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
                  e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                  
                  final retryResponse = await _dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (err) {
                _isRefreshing = false;
                await _handleLogout();
                return handler.next(e);
              }
            } else if (refreshToken == null) {
              await _handleLogout();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    get_x.Get.offAllNamed('/login-pin');
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
    );
  }

  // แปลง Bytes เป็น String HEX ตัวพิมพ์ใหญ่ (ไม่มี :) เพื่อให้เทียบง่าย
  String _formatFingerprint(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join('');
  }

  Dio get instance => _dio;
}