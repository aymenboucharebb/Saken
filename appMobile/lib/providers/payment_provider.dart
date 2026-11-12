import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment.dart';
import '../repositories/payment_repository.dart';
import 'auth_provider.dart';
import 'contribution_provider.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(dioClient: ref.watch(dioClientProvider));
});

final paymentsProvider =
    AsyncNotifierProvider<PaymentsNotifier, List<Payment>>(PaymentsNotifier.new);

class PaymentsNotifier extends AsyncNotifier<List<Payment>> {
  @override
  Future<List<Payment>> build() {
    return ref.read(paymentRepositoryProvider).fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(paymentRepositoryProvider).fetchAll(),
    );
  }

  Future<Payment> createPayment({
    required int contributionId,
    required double amountPaid,
    required String date,
    String? receiptPath,
  }) async {
    final payment = await ref.read(paymentRepositoryProvider).create(
          contributionId: contributionId,
          amountPaid: amountPaid,
          date: date,
          receiptPath: receiptPath,
        );
    await refresh();
    await ref.read(contributionsProvider.notifier).refresh();
    ref.invalidate(contributionDetailProvider(contributionId));
    return payment;
  }
}

final paymentDetailProvider = FutureProvider.family<Payment, int>((ref, id) {
  return ref.read(paymentRepositoryProvider).fetchOne(id);
});
