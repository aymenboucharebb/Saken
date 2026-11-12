import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../providers/app_startup_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const String arabicSlogan = 'إقامتنا مسؤوليتنا كامل';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Déclenche / observe l'amorçage (logique hors UI).
    ref.watch(appStartupProvider);

    final width = MediaQuery.sizeOf(context).width;
    final logoWidth = (width * 0.62).clamp(220.0, 320.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/branding/splash.png',
                      width: logoWidth,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                    ),
                    const SizedBox(height: 28),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        arabicSlogan,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: SakenTheme.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: SakenTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
