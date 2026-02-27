import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as get_x;
import 'package:my_app/core/service/api_constants.dart';

class ApiService {
  late Dio _dio;
  final storage = const FlutterSecureStorage();
  bool _isRefreshing = false;
 //pinning
  //  1. ใส่ค่า SHA-256 Fingerprint ของ Server คุณที่นี่
  final String _trustedFingerprint =
      " 9A:1C:C2:76:08:E9:36:8D:EA:2C:C4:BB:9D:EC:46:22:89:6E:63:8C:EC:FB:12:FE:AC:AE:C5:2D:EA:B8:68:19";
      // "45:4C:36:13:A7:03:3B:ED:E3:34:65:8F:91:7D:D6:90:9D:EB:28:AC:F1:B4:D3:1F:19:45:28:89:85:4D:32:8E";
  ApiService() {
    _dio = _createDioInstance(); // สร้าง instance หลัก
    _setupInterceptors(); // ตั้งค่า Interceptor
  }

  // ฟังก์ชันรวมศูนย์สำหรับสร้าง Dio พร้อม SSL Pinning
  Dio _createDioInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        // connectTimeout: const Duration(seconds: 10),
        // receiveTimeout: const Duration(seconds: 10),
      ),
    );

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
            // 1. นำ cert.der (ข้อมูลดิบของใบเซอร์) มาผ่านกระบวนการ SHA256 Hash
            // 2. ดึงค่า .bytes ออกมา เพื่อส่งเข้าฟังก์ชัน _formatFingerprint
            final serverFingerprint = _formatFingerprint(
              sha256.convert(cert.der).bytes,
            );

            // print("SERVER FINGERPRINT: $serverFingerprint");

            // ตรวจสอบกับค่าที่เชื่อถือได้
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
          String? token = await storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // กรณีเป็นหน้า Login ให้ Controller จัดการ Error เอง
            if (e.requestOptions.path.contains(ApiConstants.login)) {
              return handler.next(e);
            }

            String? refreshToken = await storage.read(key: 'refreshToken');

            if (refreshToken != null && !_isRefreshing) {
              _isRefreshing = true;
              try {
                // ใช้ฟังก์ชันสร้าง Dio ตัวใหม่ที่มี SSL Pinning เหมือนตัวหลัก
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

                  // ยิง Request เดิมซ้ำด้วย Token ใหม่
                  e.requestOptions.headers['Authorization'] =
                      'Bearer $newAccess';
                  final retryResponse = await _dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (err) {
                _isRefreshing = false;
                await storage.deleteAll();
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

  // Helper สำหรับแปลงพวง Bytes เป็น String Fingerprint
  String _formatFingerprint(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  Dio get instance => _dio;
}