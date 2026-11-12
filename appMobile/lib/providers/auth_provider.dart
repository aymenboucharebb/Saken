import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dio_client.dart';
import '../core/storage_service.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  factory AuthState.unknown() {
    return const AuthState(status: AuthStatus.unknown, isLoading: true);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
    );
  }

  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DioClient(
    storage: storage,
    onUnauthorized: () {
      ref.read(authProvider.notifier).onUnauthorized();
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dioClient: ref.watch(dioClientProvider),
    storage: ref.watch(storageServiceProvider),
  );
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.unknown();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Applique une session déjà validée (ex. AppInitializer).
  void setAuthenticated(User user) {
    state = AuthState.authenticated(user);
  }

  void setUnauthenticated({String? errorMessage}) {
    state = AuthState.unauthenticated(errorMessage: errorMessage);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repo.login(email, password);
      state = AuthState.authenticated(session.user);
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.message);
      return false;
    } catch (_) {
      state = AuthState.unauthenticated(
        errorMessage: 'Une erreur est survenue. Réessayez.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repo.logout();
    state = AuthState.unauthenticated();
  }

  void onUnauthorized() {
    state = AuthState.unauthenticated(
      errorMessage: 'Session expirée. Veuillez vous reconnecter.',
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
