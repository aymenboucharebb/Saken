import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'config.dart';

/// Persistance sécurisée du token Sanctum.
class StorageService {
  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) {
    return _storage.write(key: AppConfig.tokenStorageKey, value: token);
  }

  Future<String?> readToken() {
    return _storage.read(key: AppConfig.tokenStorageKey);
  }

  Future<void> clearToken() {
    return _storage.delete(key: AppConfig.tokenStorageKey);
  }
}
