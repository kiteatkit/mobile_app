import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SupabaseManager {
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: 'https://dojnzaydmaxlmxymwbbo.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvam56YXlkbWF4bG14eW13YmJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3NTI0ODQsImV4cCI6MjA3MjMyODQ4NH0.vCtepj8M4Me9fYCWf-Z0n2_siaaLuBPmfWv1abHQ3ko',
        httpClient: http.Client(),
      );
    } catch (e) {
      print('Ошибка инициализации Supabase: $e');
      // Попробуем без кастомного HTTP клиента
      try {
        await Supabase.initialize(
          url: 'https://dojnzaydmaxlmxymwbbo.supabase.co',
          anonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvam56YXlkbWF4bG14eW13YmJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3NTI0ODQsImV4cCI6MjA3MjMyODQ4NH0.vCtepj8M4Me9fYCWf-Z0n2_siaaLuBPmfWv1abHQ3ko',
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
