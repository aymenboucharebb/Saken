import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/contribution.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/payment_provider.dart';
import '../widgets/async_body.dart';

class NewPaymentScreen extends ConsumerStatefulWidget {
  const NewPaymentScreen({super.key, this.preselectedContributionId});

  final int? preselectedContributionId;

  @override
  ConsumerState<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends ConsumerState<NewPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _picker = ImagePicker();

  int? _contributionId;
  DateTime _date = DateTime.now();
  XFile? _receipt;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _contributionId = widget.preselectedContributionId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickReceipt() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _receipt = file);
    }
  }

  Future<void> _submit(List<Contribution> openContributions) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final contributionId =
        _contributionId ?? openContributions.firstOrNull?.id;
    if (contributionId == null) {
      setState(() => _error = 'Choisissez une cotisation.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final amount = double.parse(
        _amountController.text.trim().replaceAll(',', '.'),
      );
      final payment = await ref.read(paymentsProvider.notifier).createPayment(
            contributionId: contributionId,
            amountPaid: amount,
            date: DateFormat('yyyy-MM-dd').format(_date),
            receiptPath: _receipt?.path,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement enregistré avec succès.')),
      );
      context.go('/payments/${payment.id}');
    } on DioException catch (e) {
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response!.data['message'].toString()
          : 'Impossible d\'enregistrer le paiement.';
      setState(() => _error = message);
    } catch (_) {
      setState(() => _error = 'Impossible d\'enregistrer le paiement.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncContributions = ref.watch(contributionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Déclarer un paiement')),
      body: AsyncBody(
        value: asyncContributions,
        onRetry: () => ref.read(contributionsProvider.notifier).refresh(),
        builder: (all) {
          final open = all.where((c) => c.isActive && c.hasRemaining).toList();

          if (open.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune cotisation ouverte avec un reste à payer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
              ),
            );
          }

          final selectedId = open.any((c) => c.id == _contributionId)
              ? _contributionId
              : open.first.id;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Cotisation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  key: ValueKey('contribution-$selectedId'),
                  initialValue: selectedId,
                  isExpanded: true,
                  items: open
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            '${c.title} — reste ${c.remainingAmountFormatted ?? ''}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _contributionId = value),
                  decoration: const InputDecoration(
                    labelText: 'Choisir la cotisation',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  enabled: !_submitting,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Montant versé (dinars)',
                    hintText: 'Ex. 2000',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Indiquez le montant.';
                    }
                    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return 'Montant invalide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date du versement', style: TextStyle(fontSize: 17)),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(_date),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _submitting ? null : _pickDate,
                ),
                const SizedBox(height: 12),
                Text('Photo du reçu (facultatif)', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickReceipt,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_receipt == null ? 'Ajouter une photo' : 'Changer la photo'),
                ),
                if (_receipt != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_receipt!.path),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _submitting ? null : () => _submit(open),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer le paiement'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
