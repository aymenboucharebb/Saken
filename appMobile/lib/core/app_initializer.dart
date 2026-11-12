import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/user.dart';

enum AppStartupStatus {
  initializing,
  readyAuthenticated,
  readyUnauthenticated,
  offline,
  failed,
}

class AppStartupResult {
  const AppStartupResult({
    required this.status,
    this.user,
    this.message,
  });

  const AppStartupResult.initializing()
      : status = AppStartupStatus.initializing,
        user = null,
        message = null;

  final AppStartupStatus status;
  final User? user;
  final String? message;

  bool get isAuthenticated => status == AppStartupStatus.readyAuthenticated;
}

/// Accès session pour l'amorçage (AuthRepository ou fake de test).
abstract interface class AuthBootstrapGateway {
  Future<String?> readStoredToken();
  Future<User> fetchMe();
  Future<void> clearSession();
}

/// Logique d'amorçage (hors UI) : réseau, token Sanctum, profil.
class AppInitializer {
  AppInitializer({
    required AuthBootstrapGateway authRepository,
    Connectivity? connectivity,
  }) : _authRepository = authRepository,
       _connectivity = connectivity ?? Connectivity();

  final AuthBootstrapGateway _authRepository;
  final Connectivity _connectivity;

  Future<AppStartupResult> run() async {
    try {
      final connections = await _connectivity.checkConnectivity();
      final hasNetwork = connections.any(
        (status) => status != ConnectivityResult.none,
      );

      if (!hasNetwork) {
        return const AppStartupResult(
          status: AppStartupStatus.offline,
          message: 'Pas de connexion Internet.',
        );
      }

      final token = await _authRepository.readStoredToken();
      if (token == null || token.isEmpty) {
        return const AppStartupResult(
          status: AppStartupStatus.readyUnauthenticated,
        );
      }

      try {
        final user = await _authRepository.fetchMe();
        return AppStartupResult(
          status: AppStartupStatus.readyAuthenticated,
          user: user,
        );
      } catch (_) {
        await _authRepository.clearSession();

        final after = await _connectivity.checkConnectivity();
        final stillOnline = after.any(
          (status) => status != ConnectivityResult.none,
        );

        if (!stillOnline) {
          return const AppStartupResult(
            status: AppStartupStatus.offline,
            message: 'Pas de connexion Internet.',
          );
        }

        return const AppStartupResult(
          status: AppStartupStatus.readyUnauthenticated,
          message: 'Session expirée. Veuillez vous reconnecter.',
        );
      }
    } catch (_) {
      return const AppStartupResult(
        status: AppStartupStatus.failed,
        message: 'Impossible de démarrer l\'application. Réessayez.',
      );
    }
  }
}
