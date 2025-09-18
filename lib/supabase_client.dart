import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SupabaseManager {
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: 'https://ggbmnlwvgcccnfnccabd.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnYm1ubHd2Z2NjY25mbmNjYWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMTc1MDUsImV4cCI6MjA3Mzc5MzUwNX0.Txc8sK4kp8q1ZWPlEN3OkhAMzS7QPbkfFFolfoDb9TU',
        httpClient: http.Client(),
      );
    } catch (e) {
      print('Ошибка инициализации Supabase: $e');
      // Попробуем без кастомного HTTP клиента
      try {
        await Supabase.initialize(
          url: 'https://ggbmnlwvgcccnfnccabd.supabase.co',
          anonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnYm1ubHd2Z2NjY25mbmNjYWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMTc1MDUsImV4cCI6MjA3Mzc5MzUwNX0.Txc8sK4kp8q1ZWPlEN3OkhAMzS7QPbkfFFolfoDb9TU',
        );
      } catch (e2) {
        throw Exception('Ошибка инициализации Supabase: $e2');
      }
    }
  }

  static SupabaseClient get client {
    if (!Supabase.instance.isInitialized) {
      throw Exception('Supabase не инициализирован');
    }
    return Supabase.instance.client;
  }
}
