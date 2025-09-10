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
    final theme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: UI.background,
      colorScheme: const ColorScheme.dark().copyWith(primary: UI.primary),
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: UI.card,
        filled: true,
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: UI.white,
        displayColor: UI.white,
      ),
    );
    return MaterialApp.router(
      title: 'BC Vikings App',
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
