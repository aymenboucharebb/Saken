import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../widgets/async_body.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({super.key, required this.paymentId});

  final int paymentId;

  String _formatDate(String raw) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPayment = ref.watch(paymentDetailProvider(paymentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du paiement')),
      body: AsyncBody(
        value: asyncPayment,
        onRetry: () => ref.invalidate(paymentDetailProvider(paymentId)),
        builder: (payment) {
          final receipt = payment.absoluteReceiptUrl;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Montant versé',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        payment.amountPaidFormatted,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Date',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        _formatDate(payment.date),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cotisation',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        payment.contribution?.title ?? '—',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Photo du reçu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (receipt == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Aucune photo de reçu n\'a été jointe.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                _AuthenticatedReceiptImage(imageUrl: receipt),
            ],
          );
        },
      ),
    );
  }
}

/// Affiche un reçu privé en injectant le Bearer Sanctum.
class _AuthenticatedReceiptImage extends ConsumerWidget {
  const _AuthenticatedReceiptImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: ref.read(storageServiceProvider).readToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;
        final headers = <String, String>{
          'Accept': 'image/*,application/octet-stream',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        };

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            httpHeaders: headers,
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 160,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Text('Impossible d\'afficher le reçu'),
            ),
          ),
        );
      },
    );
  }
}
