import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_initializer.dart';
import '../../providers/app_startup_provider.dart';

class OfflineScreen extends ConsumerWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);
    final theme = Theme.of(context);
    final isRetrying = startup.status == AppStartupStatus.initializing;

    final message = startup.message ??
        (startup.status == AppStartupStatus.failed
            ? 'Impossible de démarrer l\'application. Réessayez.'
            : 'Pas de connexion Internet.');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 24),
              Text(
                'Hors ligne',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: isRetrying
                    ? null
                    : () => ref.read(appStartupProvider.notifier).retry(),
                icon: isRetrying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(isRetrying ? 'Connexion…' : 'Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
