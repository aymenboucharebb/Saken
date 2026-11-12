import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_icons.dart';

/// Raccourcis « Mon espace » (sans CTA paiement — réservé à la carte financière).
class MySpaceSection extends StatelessWidget {
  const MySpaceSection({super.key});

  static const Color _navy = Color(0xFF172B4D);
  static const Color _softBlue = Color(0xFFEAF1F8);
  static const Color _muted = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mon espace',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _navy,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ShortcutCard(
                icon: AppIcons.receipt,
                title: 'Mes cotisations',
                subtitle: 'Consulter mes charges.',
                onTap: () => context.go('/contributions'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ShortcutCard(
                icon: AppIcons.wallet,
                title: 'Historique',
                subtitle: 'Paiements et reçus.',
                onTap: () => context.go('/payments'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: MySpaceSection._navy.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: MySpaceSection._navy.withValues(alpha: 0.06),
        highlightColor: MySpaceSection._navy.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: MySpaceSection._softBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppIcons.size,
                  color: MySpaceSection._navy,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: MySpaceSection._navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: MySpaceSection._muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
