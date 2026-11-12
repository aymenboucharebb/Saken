import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saken/core/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('Saken theme builds', () {
    final theme = SakenTheme.light();
    expect(theme, isA<ThemeData>());
    expect(theme.scaffoldBackgroundColor, SakenTheme.background);
  });
}
