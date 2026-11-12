import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/contribution.dart';
import '../models/payment.dart';
import 'contribution_provider.dart';
import 'payment_provider.dart';

/// État UI du dashboard (logique hors widgets).
class DashboardData {
  const DashboardData({
    required this.focusContribution,
    required this.isFullyPaid,
    required this.remainingFormatted,
    required this.totalFormatted,
    required this.paidFormatted,
    required this.progress,
    required this.recentPayments,
  });

  final Contribution? focusContribution;
  final bool isFullyPaid;
  final String remainingFormatted;
  final String? totalFormatted;
  final String? paidFormatted;
  final double? progress;
  final List<Payment> recentPayments;

  int? get focusContributionId => focusContribution?.id;

  String get contributionTitle =>
      focusContribution?.title ?? 'Aucune cotisation';

  factory DashboardData.from({
    required List<Contribution> contributions,
    required List<Payment> payments,
  }) {
    final focus = _selectFocus(contributions);

    if (focus == null) {
      return DashboardData(
        focusContribution: null,
        isFullyPaid: true,
        remainingFormatted: '0 DZD',
        totalFormatted: null,
        paidFormatted: null,
        progress: null,
        recentPayments: payments.take(3).toList(),
      );
    }

    final remaining = focus.remainingAmount;
    final total = focus.amountPerApartment;
    final isPaid = focus.isFullyPaid == true || !focus.hasRemaining;
    final paidAmount = remaining == null
        ? null
        : (total - remaining).clamp(0, total).toDouble();
    final progress = (remaining != null && total > 0)
        ? ((total - remaining) / total).clamp(0.0, 1.0)
        : null;

    return DashboardData(
      focusContribution: focus,
      isFullyPaid: isPaid,
      remainingFormatted: isPaid
          ? '0 DZD'
          : (focus.remainingAmountFormatted ??
              _formatDzd(remaining ?? total)),
      totalFormatted: focus.amountPerApartmentFormatted,
      paidFormatted: paidAmount == null ? null : _formatDzd(paidAmount),
      progress: progress,
      recentPayments: payments.take(3).toList(),
    );
  }

  static Contribution? _selectFocus(List<Contribution> items) {
    if (items.isEmpty) return null;

    final due = items.where((c) => c.isActive && c.hasRemaining);
    if (due.isNotEmpty) return due.first;

    final active = items.where((c) => c.isActive);
    if (active.isNotEmpty) return active.first;

    return items.first;
  }

  static String _formatDzd(double amount) {
    final formatted = NumberFormat('#,##0.##', 'fr_FR').format(amount);
    return '$formatted DZD';
  }
}

/// Compose cotisations + paiements sans nouvel appel HTTP.
final dashboardProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final contributions = ref.watch(contributionsProvider);
  final payments = ref.watch(paymentsProvider);

  if (contributions.isLoading || payments.isLoading) {
    return const AsyncValue.loading();
  }

  if (contributions.hasError) {
    return AsyncValue.error(
      contributions.error!,
      contributions.stackTrace ?? StackTrace.current,
    );
  }

  if (payments.hasError) {
    return AsyncValue.error(
      payments.error!,
      payments.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncValue.data(
    DashboardData.from(
      contributions: contributions.requireValue,
      payments: payments.requireValue,
    ),
  );
});

Future<void> refreshDashboard(WidgetRef ref) async {
  await Future.wait([
    ref.read(contributionsProvider.notifier).refresh(),
    ref.read(paymentsProvider.notifier).refresh(),
  ]);
}
