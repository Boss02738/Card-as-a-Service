import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:my_app/core/api_constants.dart';

class ApiService {
  final Dio _dio = Dio();
  final storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // ดึง Access Token มาใส่ Header ทุกครั้ง
        String? token = await storage.read(key: 'accessToken');
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // ถ้า Server ตอบกลับมาว่า 401 (Token Expired)
        if (e.response?.statusCode == 401) {
          String? refreshToken = await storage.read(key: 'refreshToken');
          
          if (refreshToken != null) {
            try {
              // 1. ส่ง Refresh Token ไปแลกชุดใหม่
              final refreshResponse = await _dio.post('/refresh', data: {
                'refreshToken': refreshToken,
              });

              if (refreshResponse.statusCode == 200) {
                // 2. เก็บ Token ใหม่ที่ได้จาก Backend (ทั้ง Access และ Refresh ตัวใหม่)
                String newAccess = refreshResponse.data['token'];
                String newRefresh = refreshResponse.data['refreshToken'];

                await storage.write(key: 'accessToken', value: newAccess);
                await storage.write(key: 'refreshToken', value: newRefresh);

                // 3. ยิง Request เดิมที่เคยพังไปใหม่อีกครั้งด้วย Token ใหม่
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                final retryResponse = await _dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (err) {
              // ถ้า Refresh ไม่ผ่าน (เช่น Refresh Token ก็หมดอายุด้วย) ให้ไล่ไป Login ใหม่
              Get.offAllNamed('/login');
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get instance => _dio;
}