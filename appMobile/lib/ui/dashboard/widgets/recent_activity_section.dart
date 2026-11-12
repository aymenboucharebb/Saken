import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/app_icons.dart';
import '../../../models/payment.dart';

/// Liste « Dernière activité » — widget présentationnel (données via props).
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, required this.payments});

  final List<Payment> payments;

  static const Color _navy = Color(0xFF172B4D);
  static const Color _muted = Color(0xFF718096);
  static const Color _softBlue = Color(0xFFEAF1F8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Dernière activité',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/payments'),
              style: TextButton.styleFrom(
                foregroundColor: _muted,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Tout voir'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          color: Colors.white,
          shadowColor: _navy.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: payments.isEmpty
              ? const _EmptyActivity()
              : Column(
                  children: [
                    for (var i = 0; i < payments.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, color: Color(0xFFEEF1F5)),
                      _ActivityTile(payment: payments[i]),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: RecentActivitySection._softBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.activity,
              size: AppIcons.sizeNav,
              color: RecentActivitySection._navy,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucune activité récente',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: RecentActivitySection._navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vos dernières opérations apparaîtront ici.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: RecentActivitySection._muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.payment});

  final Payment payment;

  String _formatDate(String raw) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = payment.contribution?.title ?? 'Paiement';

    return ListTile(
      onTap: () => context.push('/payments/${payment.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: RecentActivitySection._softBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          AppIcons.moneyReceive,
          size: AppIcons.size,
          color: RecentActivitySection._navy,
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: RecentActivitySection._navy,
        ),
      ),
      subtitle: Text(
        _formatDate(payment.date),
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: RecentActivitySection._muted,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            payment.amountPaidFormatted,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: RecentActivitySection._navy,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: RecentActivitySection._softBlue,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Enregistré',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: RecentActivitySection._navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
