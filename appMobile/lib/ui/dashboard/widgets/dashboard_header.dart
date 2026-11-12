import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/user.dart';

/// Header Fintech de l'écran d'accueil (marque + avatar + salutation).
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.user,
    this.onLogout,
  });

  final User? user;
  final VoidCallback? onLogout;

  static const Color _navy = Color(0xFF172B4D);
  static const Color _secondary = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    final firstName = _firstName(user?.name);
    final initials = _initials(user?.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Saken',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: _navy,
              ),
            ),
            const Spacer(),
            _ResidentAvatar(
              initials: initials,
              onLogout: onLogout,
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          firstName.isEmpty ? 'Bonjour 👋' : 'Bonjour, $firstName 👋',
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.4,
            color: _navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenue dans votre espace résident.',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: _secondary,
          ),
        ),
      ],
    );
  }

  static String _firstName(String? fullName) {
    if (fullName == null) return '';
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  static String _initials(String? fullName) {
    if (fullName == null) return '?';
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _ResidentAvatar extends StatelessWidget {
  const _ResidentAvatar({
    required this.initials,
    this.onLogout,
  });

  final String initials;
  final VoidCallback? onLogout;

  static const Color _navy = Color(0xFF172B4D);
  static const Color _softBlue = Color(0xFFEAF1F8);

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _softBlue,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: _navy,
          letterSpacing: 0.2,
        ),
      ),
    );

    if (onLogout == null) return avatar;

    return PopupMenuButton<String>(
      tooltip: 'Compte',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'logout') onLogout?.call();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'logout',
          child: Text('Déconnexion'),
        ),
      ],
      child: avatar,
    );
  }
}
