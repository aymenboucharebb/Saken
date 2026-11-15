/// Configuration réseau de l'application Saken.
class AppConfig {
  AppConfig._();

  /// Base URL de l'API Laravel (préfixe `/api`).
  ///
  /// Surcharge au build :
  /// `flutter run --dart-define=API_BASE_URL=https://votre-app.onrender.com/api`
  ///
  /// Défaut local (émulateur Android) : `10.0.2.2` → localhost machine hôte.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://saken-1-bc4z.onrender.com/api',
  );

  static const String tokenStorageKey = 'saken_auth_token';
}
