import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_startup_provider.dart';
import '../providers/auth_provider.dart';
import '../ui/contributions/contribution_detail_screen.dart';
import '../ui/contributions/contributions_screen.dart';
import '../ui/dashboard/dashboard_screen.dart';
import '../ui/login/login_screen.dart';
import '../ui/offline/offline_screen.dart';
import '../ui/payments/new_payment_screen.dart';
import '../ui/payments/payment_detail_screen.dart';
import '../ui/payments/payments_screen.dart';
import '../ui/shell/home_shell.dart';
import '../ui/splash/splash_screen.dart';
import 'app_initializer.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final startup = ref.read(appStartupProvider);
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      switch (startup.status) {
        case AppStartupStatus.initializing:
          return loc == '/splash' ? null : '/splash';
        case AppStartupStatus.offline:
        case AppStartupStatus.failed:
          return loc == '/offline' ? null : '/offline';
        case AppStartupStatus.readyAuthenticated:
        case AppStartupStatus.readyUnauthenticated:
          break;
      }

      final loggingIn = loc == '/login';
      final onGate =
          loc == '/splash' || loc == '/login' || loc == '/offline';

      if (auth.status == AuthStatus.authenticated) {
        return onGate ? '/dashboard' : null;
      }

      if (auth.status == AuthStatus.unauthenticated) {
        return loggingIn ? null : '/login';
      }

      // Auth encore unknown après startup prêt : rester / envoyer splash.
      return loc == '/splash' ? null : '/splash';
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/offline',
        name: 'offline',
        builder: (context, state) => const OfflineScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contributions',
                name: 'contributions',
                builder: (context, state) => const ContributionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/payments',
                name: 'payments',
                builder: (context, state) => const PaymentsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/contributions/:id',
        name: 'contribution-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ContributionDetailScreen(contributionId: id);
        },
      ),
      GoRoute(
        path: '/payments/new',
        name: 'payment-new',
        builder: (context, state) {
          final extra = state.extra;
          final preselected = extra is int ? extra : null;
          return NewPaymentScreen(preselectedContributionId: preselected);
        },
      ),
      GoRoute(
        path: '/payments/:id',
        name: 'payment-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PaymentDetailScreen(paymentId: id);
        },
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen<AuthState>(authProvider, (previous, next) => notifyListeners());
    _ref.listen<AppStartupResult>(
      appStartupProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref _ref;
}
