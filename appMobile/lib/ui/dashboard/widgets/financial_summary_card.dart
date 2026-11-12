import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/dashboard_provider.dart';

/// Carte financière claire — reste à payer + CTA unique.
class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({
    super.key,
    required this.data,
    required this.onDeclarePayment,
  });

  final DashboardData data;
  final VoidCallback onDeclarePayment;

  static const Color _navy = Color(0xFF172B4D);
  static const Color _muted = Color(0xFF718096);
  static const Color _softBlue = Color(0xFFEAF1F8);
  static const Color _accent = Color(0xFFF59E0B);
  static const Color _paidGreen = Color(0xFF2E7D4F);

  @override
  Widget build(BuildContext context) {
    final isPaid = data.isFullyPaid;

    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: _navy.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'MA SITUATION FINANCIÈRE',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: _muted,
                    ),
                  ),
                ),
                _StatusBadge(isPaid: isPaid),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              isPaid ? 'Situation' : 'Reste à payer',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPaid ? 'Tout est payé' : data.remainingFormatted,
              style: GoogleFonts.nunito(
                fontSize: isPaid ? 26 : 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
                color: isPaid ? _paidGreen : _accent,
              ),
            ),
            if (data.focusContribution == null) ...[
              const SizedBox(height: 8),
              Text(
                'Aucune cotisation ouverte pour le moment.',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                  height: 1.4,
                ),
              ),
            ] else ...[
              const SizedBox(height: 18),
              _MetaRow(label: 'Cotisation', value: data.contributionTitle),
              if (data.totalFormatted != null) ...[
                const SizedBox(height: 10),
                _MetaRow(
                  label: 'Total des charges',
                  value: data.totalFormatted!,
                ),
              ],
              if (data.paidFormatted != null) ...[
                const SizedBox(height: 10),
                _MetaRow(label: 'Déjà payé', value: data.paidFormatted!),
              ],
              if (data.progress != null) ...[
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: data.progress,
                    minHeight: 7,
                    backgroundColor: _softBlue,
                    color: isPaid ? _paidGreen : _accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(data.progress! * 100).round()} % payé',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
              ],
            ],
            if (!isPaid) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDeclarePayment,
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Déclarer un paiement'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF718096),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF172B4D),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final background =
        isPaid ? const Color(0xFFE6F4EA) : const Color(0xFFFFF4E5);
    final foreground =
        isPaid ? const Color(0xFF2E7D4F) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPaid ? 'Payé' : 'À payer',
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}
