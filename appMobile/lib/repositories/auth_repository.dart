import 'package:dio/dio.dart';

import '../core/app_initializer.dart';
import '../core/dio_client.dart';
import '../core/storage_service.dart';
import '../models/user.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;
}

/// Accès API d'authentification Sanctum.
class AuthRepository implements AuthBootstrapGateway {
  AuthRepository({
    required DioClient dioClient,
    required StorageService storage,
  }) : _dio = dioClient.dio,
       _storage = storage;

  final Dio _dio;
  final StorageService _storage;

  Future<AuthSession> login(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/login',
        data: {
          'email': email.trim(),
          'password': password,
          'device_name': 'flutter',
        },
      );

      final data = response.data;
      if (data == null || data['token'] == null || data['user'] == null) {
        throw AuthException('Réponse de connexion invalide.');
      }

      final token = data['token'] as String;
      final user = User.fromJson(Map<String, dynamic>.from(data['user'] as Map));

      await _storage.saveToken(token);

      return AuthSession(token: token, user: user);
    } on DioException catch (e) {
      throw AuthException(_messageFromDio(e));
    }
  }

  Future<User> fetchMe() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/me');
      final data = response.data;
      final userJson = data?['data'] ?? data;
      if (userJson is! Map) {
        throw AuthException('Impossible de charger le profil.');
      }
      return User.fromJson(Map<String, dynamic>.from(userJson));
    } on DioException catch (e) {
      throw AuthException(_messageFromDio(e));
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/logout');
    } on DioException {
      // On ignore les erreurs réseau : on déconnecte localement quand même.
    } finally {
      await _storage.clearToken();
    }
  }

  Future<String?> readStoredToken() => _storage.readToken();

  Future<void> clearSession() => _storage.clearToken();

  String _messageFromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 422 && data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (status == 401) {
      return 'Identifiants incorrects.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}
