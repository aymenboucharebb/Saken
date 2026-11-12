import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/my_space_section.dart';
import 'widgets/recent_activity_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const Color _navy = Color(0xFF172B4D);
  static const Color _muted = Color(0xFF718096);
  static const Color _bg = Color(0xFFF7F8FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: DashboardHeader(
                user: user,
                onLogout: auth.isLoading
                    ? null
                    : () => ref.read(authProvider.notifier).logout(),
              ),
            ),
            Expanded(
              child: dashboard.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                error: (error, _) => _DashboardError(
                  onRetry: () => refreshDashboard(ref),
                ),
                data: (data) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  children: [
                    FinancialSummaryCard(
                      data: data,
                      onDeclarePayment: () {
                        context.push(
                          '/payments/new',
                          extra: data.focusContributionId,
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const MySpaceSection(),
                    const SizedBox(height: 28),
                    RecentActivitySection(payments: data.recentPayments),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Impossible de charger votre espace.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DashboardScreen._navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre connexion puis réessayez.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DashboardScreen._muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: DashboardScreen._navy,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
