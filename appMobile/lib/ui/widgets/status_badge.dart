import 'package:flutter/material.dart';

import '../../core/theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge.paid({super.key})
      : label = 'Payé',
        background = const Color(0xFFE6F4EA),
        foreground = SakenTheme.paidGreen;

  const StatusBadge.due({super.key})
      : label = 'À payer',
        background = const Color(0xFFFFF4E5),
        foreground = SakenTheme.dueAmber;

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
