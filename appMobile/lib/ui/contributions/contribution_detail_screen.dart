import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/contribution_provider.dart';
import '../widgets/async_body.dart';
import '../widgets/status_badge.dart';

class ContributionDetailScreen extends ConsumerWidget {
  const ContributionDetailScreen({super.key, required this.contributionId});

  final int contributionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(contributionDetailProvider(contributionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail cotisation')),
      body: AsyncBody(
        value: asyncDetail,
        onRetry: () => ref.invalidate(contributionDetailProvider(contributionId)),
        builder: (item) {
          final paid = item.isFullyPaid == true || !item.hasRemaining;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          paid ? const StatusBadge.paid() : const StatusBadge.due(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.isActive ? 'Cotisation ouverte' : 'Cotisation fermée',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Montant demandé',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                      ),
                      Text(
                        item.amountPerApartmentFormatted,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Reste à payer',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                      ),
                      Text(
                        item.remainingAmountFormatted ??
                            item.amountPerApartmentFormatted,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: paid
                                  ? const Color(0xFF2E7D4F)
                                  : const Color(0xFFB86E00),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (item.isActive && item.hasRemaining) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push(
                    '/payments/new',
                    extra: item.id,
                  ),
                  child: const Text('Déclarer un paiement'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
