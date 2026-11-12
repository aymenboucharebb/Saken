import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_initializer.dart';
import 'auth_provider.dart';

final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

final appStartupProvider =
    NotifierProvider<AppStartupNotifier, AppStartupResult>(
  AppStartupNotifier.new,
);

class AppStartupNotifier extends Notifier<AppStartupResult> {
  @override
  AppStartupResult build() {
    Future.microtask(run);
    return const AppStartupResult.initializing();
  }

  Future<void> run() async {
    state = const AppStartupResult.initializing();

    final result = await ref.read(appInitializerProvider).run();

    switch (result.status) {
      case AppStartupStatus.readyAuthenticated:
        if (result.user != null) {
          ref.read(authProvider.notifier).setAuthenticated(result.user!);
        }
      case AppStartupStatus.readyUnauthenticated:
        ref.read(authProvider.notifier).setUnauthenticated(
              errorMessage: result.message,
            );
      case AppStartupStatus.offline:
      case AppStartupStatus.failed:
      case AppStartupStatus.initializing:
        break;
    }

    state = result;
  }

  Future<void> retry() => run();
}
