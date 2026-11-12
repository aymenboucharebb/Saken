import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_icons.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        indicatorColor: AppIcons.navy.withValues(alpha: 0.08),
        destinations: const [
          NavigationDestination(
            icon: Icon(
              AppIcons.home,
              size: AppIcons.sizeNav,
              color: AppIcons.muted,
            ),
            selectedIcon: Icon(
              AppIcons.homeBold,
              size: AppIcons.sizeNav,
              color: AppIcons.navy,
            ),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(
              AppIcons.receipt,
              size: AppIcons.sizeNav,
              color: AppIcons.muted,
            ),
            selectedIcon: Icon(
              AppIcons.receiptBold,
              size: AppIcons.sizeNav,
              color: AppIcons.navy,
            ),
            label: 'Cotisations',
          ),
          NavigationDestination(
            icon: Icon(
              AppIcons.wallet,
              size: AppIcons.sizeNav,
              color: AppIcons.muted,
            ),
            selectedIcon: Icon(
              AppIcons.walletBold,
              size: AppIcons.sizeNav,
              color: AppIcons.navy,
            ),
            label: 'Paiements',
          ),
        ],
      ),
    );
  }
}
