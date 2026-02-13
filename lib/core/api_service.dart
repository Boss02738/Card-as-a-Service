import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as get_x; // ป้องกันชื่อซ้ำกับ dio
import 'package:my_app/core/api_constants.dart';

class ApiService {
  final Dio _dio = Dio();
  final storage = const FlutterSecureStorage();
  bool _isRefreshing = false; // สถานะว่ากำลังแลก Token อยู่หรือไม่
  List<ErrorInterceptorHandler> _failedRequests = []; // เก็บ Request ที่ค้างไว้

  ApiService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // ดึง Access Token มาใส่ Header ทุกครั้ง
        String? token = await storage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // ถ้า Server ตอบกลับมาว่า 401 (Unauthorized)
        if (e.response?.statusCode == 401) {
          String? refreshToken = await storage.read(key: 'refreshToken');

          if (refreshToken != null) {
            if (!_isRefreshing) {
              _isRefreshing = true;
              try {
                // ใช้ Dio instance ใหม่ยิงเพื่อไม่ให้ติด Interceptor เดิม (ป้องกัน Loop)
                final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
                final response = await refreshDio.post(ApiConstants.refreshToken, data: {
                  'refreshToken': refreshToken,
                });

                if (response.statusCode == 200) {
                  String newAccess = response.data['token'];
                  String newRefresh = response.data['refreshToken'];

                  // บันทึก Token ใหม่
                  await storage.write(key: 'accessToken', value: newAccess);
                  await storage.write(key: 'refreshToken', value: newRefresh);

                  _isRefreshing = false;

                  // ยิง Request เดิมที่เคยพังไปใหม่
                  e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                  final retryResponse = await _dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (err) {
                _isRefreshing = false;
                // ถ้า Refresh ไม่ผ่าน ให้กลับไป Login
                await storage.deleteAll();
                get_x.Get.offAllNamed('/login');
              }
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get instance => _dio;
}