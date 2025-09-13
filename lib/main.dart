import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'supabase_client.dart';
import 'router.dart';
import 'ui/ui_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: UI.background,
      colorScheme: ColorScheme.light(
        primary: UI.primary,
        secondary: UI.accent,
        surface: UI.card,
        background: UI.background,
        onPrimary: UI.textPrimary,
        onSecondary: UI.black,
        onSurface: UI.black,
        onBackground: UI.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: UI.card,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UI.radiusLg),
          borderSide: const BorderSide(color: UI.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UI.radiusLg),
          borderSide: const BorderSide(color: UI.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UI.radiusLg),
          borderSide: const BorderSide(color: UI.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: UI.primary,
          foregroundColor: UI.textPrimary,
          elevation: 4,
          shadowColor: UI.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UI.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: UI.card,
        elevation: 0,
        shadowColor: UI.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UI.radiusLg),
          side: const BorderSide(color: UI.border),
        ),
      ),
      textTheme: ThemeData.light().textTheme
          .apply(
            bodyColor: UI.textPrimary,
            displayColor: UI.textPrimary,
            fontFamily: UI.fontFamily,
          )
          .copyWith(
            headlineLarge: TextStyle(
              fontFamily: UI.fontFamily,
              fontWeight: UI.fontWeightBold,
              color: UI.textPrimary,
            ),
            headlineMedium: TextStyle(
              fontFamily: UI.fontFamily,
              fontWeight: UI.fontWeightSemiBold,
              color: UI.textPrimary,
            ),
            titleLarge: TextStyle(
              fontFamily: UI.fontFamily,
              fontWeight: UI.fontWeightSemiBold,
              color: UI.textPrimary,
            ),
            titleMedium: TextStyle(
              fontFamily: UI.fontFamily,
              fontWeight: UI.fontWeightMedium,
              color: UI.textPrimary,
            ),
            bodyLarge: TextStyle(
              fontFamily: UI.fontFamily,
              fontWeight: UI.fontWeightRegular,
              color: UI.textPrimary,
            ),
            bodyMedium: TextStyle(
              fontFamily: UI.fontFamily,
              fontWeight: UI.fontWeightRegular,
              color: UI.textSecondary,
            ),
            bodySmall: TextStyle(
              fontFamily: UI.fontFamily,
              fontWeight: UI.fontWeightRegular,
              color: UI.textMuted,
            ),
          ),
    );
    return MaterialApp.router(
      title: 'Викинги',
      theme: theme,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
      locale: const Locale('ru', 'RU'),
    );
  }
}

// Стартовый шаблон удалён. Навигация определяется в router.dart
