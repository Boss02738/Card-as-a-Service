import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as get_x; // ป้องกันชื่อซ้ำกับ dio
import 'package:my_app/core/service/api_constants.dart';

class ApiService {
  final Dio _dio = Dio();
  final storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  ApiService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    //ให้ dio ยอมรับ cer ssl ทุกตัว
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

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
          // 1. ถ้าเป็น 401 (Unauthorized / Locked)
          if (e.response?.statusCode == 401) {
            // จุดที่ 1: ถ้าเกิด Error ที่หน้า Login ห้าม Interceptor จัดการเองเด็ดขาด
            // ปล่อยให้ PinLoginController เป็นคนรับ Error ไปโชว์ Dialog หรือเช็ค Locked เอง
            if (e.requestOptions.path.contains(ApiConstants.login)) {
              return handler.next(e);
            }

            // 2. ถ้าไม่ใช่หน้า Login ให้พยายาม Refresh Token
            String? refreshToken = await storage.read(key: 'refreshToken');
            if (refreshToken != null && !_isRefreshing) {
              _isRefreshing = true;
              try {
                final refreshDio = Dio(
                  BaseOptions(baseUrl: ApiConstants.baseUrl),
                );
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

                  // ยิง Request เดิมซ้ำ
                  e.requestOptions.headers['Authorization'] =
                      'Bearer $newAccess';
                  final retryResponse = await _dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (err) {
                _isRefreshing = false;
                // จุดที่ 2: ถ้า Refresh พังจริงๆ ถึงค่อยดีดออกไปหน้าแรก
                await storage.deleteAll();
                get_x.Get.offAllNamed('/login-pin');
                return handler.next(e);
              }
            } else if (refreshToken == null) {
              // ไม่มี Refresh Token และไม่ใช่หน้า Login ให้ดีดออก
              get_x.Get.offAllNamed('/login-pin');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get instance => _dio;
}
