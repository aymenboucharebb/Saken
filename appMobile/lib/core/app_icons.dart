import 'package:flutter/widgets.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Catalogue Iconsax centralisé (Linear = défaut, Bold = `_copy`).
class AppIcons {
  AppIcons._();

  static const double size = 22;
  static const double sizeNav = 24;

  static const Color navy = Color(0xFF172B4D);
  static const Color muted = Color(0xFF718096);
  static const Color accent = Color(0xFFF59E0B);

  // —— Linear ——
  static const IconData home = Iconsax.home_2;
  static const IconData receipt = Iconsax.receipt_2;
  static const IconData wallet = Iconsax.wallet_2;
  static const IconData cardAdd = Iconsax.card_add;
  static const IconData arrowRight = Iconsax.arrow_right_3;
  static const IconData moneyReceive = Iconsax.money_recive;
  static const IconData activity = Iconsax.activity;

  // —— Bold (navigation active) ——
  static const IconData homeBold = Iconsax.home_2_copy;
  static const IconData receiptBold = Iconsax.receipt_2_copy;
  static const IconData walletBold = Iconsax.wallet_2_copy;
}
