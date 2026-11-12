import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/contribution_provider.dart';
import '../widgets/async_body.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

class ContributionsScreen extends ConsumerWidget {
  const ContributionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncContributions = ref.watch(contributionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes cotisations')),
      body: AsyncBody(
        value: asyncContributions,
        onRetry: () => ref.read(contributionsProvider.notifier).refresh(),
        builder: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Aucune cotisation pour le moment',
              subtitle: 'Dès qu\'une cotisation sera ouverte, elle apparaîtra ici.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(contributionsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = items[index];
                final paid = item.isFullyPaid == true || !item.hasRemaining;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/contributions/${item.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              paid ? const StatusBadge.paid() : const StatusBadge.due(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Montant demandé : ${item.amountPerApartmentFormatted}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reste à payer',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          Text(
                            item.remainingAmountFormatted ??
                                item.amountPerApartmentFormatted,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: paid
                                      ? const Color(0xFF2E7D4F)
                                      : const Color(0xFFB86E00),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
