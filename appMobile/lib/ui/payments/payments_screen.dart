import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/payment_provider.dart';
import '../widgets/async_body.dart';
import '../widgets/empty_state.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  String _formatDate(String raw) {
    try {
      final date = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPayments = ref.watch(paymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes paiements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payments/new'),
        icon: const Icon(Icons.add),
        label: const Text('Déclarer'),
      ),
      body: AsyncBody(
        value: asyncPayments,
        onRetry: () => ref.read(paymentsProvider.notifier).refresh(),
        builder: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.payments_outlined,
              title: 'Aucun paiement pour le moment',
              subtitle: 'Quand vous déclarerez un versement, il apparaîtra ici.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(paymentsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    title: Text(
                      item.amountPaidFormatted,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      '${_formatDate(item.date)}\n${item.contribution?.title ?? 'Cotisation'}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.35,
                          ),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/payments/${item.id}'),
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
