import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

/// KuwentoBuddy Color Palette - Soft Pastel Blues & Whites
/// Modern, age-neutral, friendly and encouraging
class KuwentoColors {
  // Primary: Soft Pastel Blue - Calming & Academic
  static const Color pastelBlue = Color(0xFF6BB3D9);
  static const Color pastelBlueLight = Color(0xFF8DC8E8);
  static const Color pastelBlueDark = Color(0xFF4A9BC4);
  static const Color deepTeal = Color(0xFF5BA4C9); // Updated to match palette

  // Secondary: Soft Sky Blue
  static const Color skyBlue = Color(0xFFB8E0F2);
  static const Color skyBlueLight = Color(0xFFDCF0FA);
  static const Color skyBlueDark = Color(0xFF92CEEB);

  // Accent: Gentle Coral for warmth
  static const Color softCoral = Color(0xFFFF8A8A);
  static const Color coralLight = Color(0xFFFFB3B3);
  static const Color coralDark = Color(0xFFE87070);

  // Legacy color references (updated to new palette)
  static const Color deepTealLight = Color(0xFF8DC8E8);
  static const Color deepTealDark = Color(0xFF4A9BC4);
  static const Color warmCream = Color(0xFFFAFCFF);
  static const Color cream = Color(0xFFF5F9FC);
  static const Color creamDark = Color(0xFFE8F0F5);

  // Buddy Colors - For character states
  static const Color buddyHappy = Color(0xFF7DD87D);
  static const Color buddyThinking = Color(0xFFFFD580);
  static const Color buddyEncouraging = Color(0xFF7BBFEA);
  static const Color buddySympathetic = Color(0xFFB8A4D9);

  // Neutral tones
  static const Color textPrimary = Color(0xFF2A3F4F);
  static const Color textSecondary = Color(0xFF5A7388);
  static const Color textMuted = Color(0xFFA0B4C4);
  
  // Surface colors - White & Light
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E2D3D);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2A3D4F);
  
  // Background
  static const Color backgroundLight = Color(0xFFF5F9FC);
  static const Color backgroundDark = Color(0xFF162230);
}

class LightModeColors {
  static const lightPrimary = KuwentoColors.pastelBlue;
  static const lightOnPrimary = Colors.white;
  static const lightPrimaryContainer = Color(0xFFDCF0FA);
  static const lightOnPrimaryContainer = KuwentoColors.pastelBlueDark;

  static const lightSecondary = KuwentoColors.softCoral;
  static const lightOnSecondary = Colors.white;
  static const lightSecondaryContainer = Color(0xFFFFE6E6);
  static const lightOnSecondaryContainer = KuwentoColors.coralDark;

  static const lightTertiary = KuwentoColors.buddyThinking;
  static const lightOnTertiary = Colors.white;

  static const lightError = Color(0xFFE85555);
  static const lightOnError = Colors.white;
  static const lightErrorContainer = Color(0xFFFFDADA);
  static const lightOnErrorContainer = Color(0xFF5C0000);

  static const lightSurface = KuwentoColors.surfaceLight;
  static const lightOnSurface = KuwentoColors.textPrimary;
  static const lightBackground = KuwentoColors.backgroundLight;
  static const lightSurfaceVariant = KuwentoColors.creamDark;
  static const lightOnSurfaceVariant = KuwentoColors.textSecondary;

  static const lightOutline = Color(0xFFD8E5EE);
  static const lightShadow = Color(0x0A000000);
}

class DarkModeColors {
  static const darkPrimary = KuwentoColors.pastelBlueLight;
  static const darkOnPrimary = KuwentoColors.pastelBlueDark;
  static const darkPrimaryContainer = KuwentoColors.pastelBlue;
  static const darkOnPrimaryContainer = Color(0xFFDCF0FA);

  static const darkSecondary = KuwentoColors.coralLight;
  static const darkOnSecondary = KuwentoColors.coralDark;
  static const darkSecondaryContainer = KuwentoColors.softCoral;
  static const darkOnSecondaryContainer = Color(0xFFFFE6E6);

  static const darkTertiary = KuwentoColors.buddyThinking;
  static const darkOnTertiary = Color(0xFF442B00);

  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);

  static const darkSurface = KuwentoColors.surfaceDark;
  static const darkOnSurface = Color(0xFFF0F5FA);
  static const darkSurfaceVariant = KuwentoColors.cardDark;
  static const darkOnSurfaceVariant = Color(0xFFB8D0E0);

  static const darkOutline = Color(0xFF3D5468);
  static const darkShadow = Color(0xFF000000);
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double storyText = 20.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    secondaryContainer: LightModeColors.lightSecondaryContainer,
    onSecondaryContainer: LightModeColors.lightOnSecondaryContainer,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
    surfaceContainerHighest: LightModeColors.lightSurfaceVariant,
    onSurfaceVariant: LightModeColors.lightOnSurfaceVariant,
    outline: LightModeColors.lightOutline,
    shadow: LightModeColors.lightShadow,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: LightModeColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: LightModeColors.lightOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: KuwentoColors.cardLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: KuwentoColors.cardLight,
    selectedItemColor: KuwentoColors.pastelBlue,
    unselectedItemColor: KuwentoColors.textMuted,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: KuwentoColors.pastelBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: KuwentoColors.pastelBlue,
      side: BorderSide(color: KuwentoColors.pastelBlue),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.light),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    secondaryContainer: DarkModeColors.darkSecondaryContainer,
    onSecondaryContainer: DarkModeColors.darkOnSecondaryContainer,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
    surfaceContainerHighest: DarkModeColors.darkSurfaceVariant,
    onSurfaceVariant: DarkModeColors.darkOnSurfaceVariant,
    outline: DarkModeColors.darkOutline,
    shadow: DarkModeColors.darkShadow,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkModeColors.darkSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: DarkModeColors.darkOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: KuwentoColors.cardDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: KuwentoColors.cardDark,
    selectedItemColor: KuwentoColors.pastelBlueLight,
    unselectedItemColor: DarkModeColors.darkOnSurfaceVariant,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: KuwentoColors.pastelBlueLight,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: KuwentoColors.pastelBlueLight,
      side: BorderSide(color: KuwentoColors.pastelBlueLight),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.dark),
);

TextTheme _buildTextTheme(Brightness brightness) {
  final color = brightness == Brightness.light
      ? KuwentoColors.textPrimary
      : Colors.white;
  
  return TextTheme(
    displayLarge: GoogleFonts.lexend(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      color: color,
    ),
    displayMedium: GoogleFonts.lexend(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w600,
      color: color,
    ),
    displaySmall: GoogleFonts.lexend(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
      color: color,
    ),
    headlineLarge: GoogleFonts.lexend(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: color,
    ),
    headlineMedium: GoogleFonts.lexend(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w600,
      color: color,
    ),
    headlineSmall: GoogleFonts.lexend(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
      color: color,
    ),
    titleLarge: GoogleFonts.lexend(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: color,
    ),
    titleMedium: GoogleFonts.lexend(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
      color: color,
    ),
    titleSmall: GoogleFonts.lexend(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
      color: color,
    ),
    labelLarge: GoogleFonts.lexend(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: color,
    ),
    labelMedium: GoogleFonts.lexend(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: color,
    ),
    labelSmall: GoogleFonts.lexend(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: color,
    ),
    bodyLarge: GoogleFonts.lexend(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.6,
      color: color,
    ),
    bodyMedium: GoogleFonts.lexend(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
      color: color,
    ),
    bodySmall: GoogleFonts.lexend(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: color,
    ),
  );
}
