import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saken/core/app_initializer.dart';
import 'package:saken/models/user.dart';

class _FakeAuth implements AuthBootstrapGateway {
  _FakeAuth({
    this.token,
    this.user,
    this.fetchError = false,
  });

  String? token;
  User? user;
  bool fetchError;
  bool cleared = false;

  @override
  Future<String?> readStoredToken() async => token;

  @override
  Future<User> fetchMe() async {
    if (fetchError || user == null) {
      throw Exception('unauthorized');
    }
    return user!;
  }

  @override
  Future<void> clearSession() async {
    cleared = true;
    token = null;
  }
}

class _FakeConnectivity implements Connectivity {
  _FakeConnectivity(this.results);

  List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final sampleUser = User(
    id: 1,
    name: 'Résident',
    email: 'resident@example.com',
    role: 'resident',
  );

  test('offline when no connectivity', () async {
    final init = AppInitializer(
      authRepository: _FakeAuth(token: 'abc'),
      connectivity: _FakeConnectivity([ConnectivityResult.none]),
    );

    final result = await init.run();

    expect(result.status, AppStartupStatus.offline);
    expect(result.message, 'Pas de connexion Internet.');
  });

  test('unauthenticated when no token', () async {
    final init = AppInitializer(
      authRepository: _FakeAuth(),
      connectivity: _FakeConnectivity([ConnectivityResult.wifi]),
    );

    final result = await init.run();

    expect(result.status, AppStartupStatus.readyUnauthenticated);
  });

  test('authenticated when token and /me succeed', () async {
    final init = AppInitializer(
      authRepository: _FakeAuth(token: 'valid', user: sampleUser),
      connectivity: _FakeConnectivity([ConnectivityResult.mobile]),
    );

    final result = await init.run();

    expect(result.status, AppStartupStatus.readyAuthenticated);
    expect(result.user?.email, 'resident@example.com');
  });

  test('expired token clears session and is unauthenticated', () async {
    final auth = _FakeAuth(token: 'expired', fetchError: true);
    final init = AppInitializer(
      authRepository: auth,
      connectivity: _FakeConnectivity([ConnectivityResult.wifi]),
    );

    final result = await init.run();

    expect(result.status, AppStartupStatus.readyUnauthenticated);
    expect(auth.cleared, isTrue);
  });
}
