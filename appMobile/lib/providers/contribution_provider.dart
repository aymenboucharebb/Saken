import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contribution.dart';
import '../repositories/contribution_repository.dart';
import 'auth_provider.dart';

final contributionRepositoryProvider = Provider<ContributionRepository>((ref) {
  return ContributionRepository(dioClient: ref.watch(dioClientProvider));
});

final contributionsProvider =
    AsyncNotifierProvider<ContributionsNotifier, List<Contribution>>(
  ContributionsNotifier.new,
);

class ContributionsNotifier extends AsyncNotifier<List<Contribution>> {
  @override
  Future<List<Contribution>> build() {
    return ref.read(contributionRepositoryProvider).fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(contributionRepositoryProvider).fetchAll(),
    );
  }
}

final contributionDetailProvider =
    FutureProvider.family<Contribution, int>((ref, id) async {
  return ref.read(contributionRepositoryProvider).fetchOne(id);
});
