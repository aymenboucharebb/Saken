import 'package:dio/dio.dart';

import 'config.dart';
import 'storage_service.dart';

typedef UnauthorizedCallback = void Function();

/// Client Dio partagé avec injection du token et gestion du 401.
class DioClient {
  DioClient({
    required StorageService storage,
    UnauthorizedCallback? onUnauthorized,
  }) : _storage = storage,
       _onUnauthorized = onUnauthorized,
       _dio = Dio(
         BaseOptions(
           baseUrl: AppConfig.apiBaseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           headers: {
             'Accept': 'application/json',
             'Content-Type': 'application/json',
           },
         ),
       ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.clearToken();
            _onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final StorageService _storage;
  final UnauthorizedCallback? _onUnauthorized;
  final Dio _dio;

  Dio get dio => _dio;
}
