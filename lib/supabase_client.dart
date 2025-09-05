import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://dojnzaydmaxlmxymwbbo.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvam56YXlkbWF4bG14eW13YmJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3NTI0ODQsImV4cCI6MjA3MjMyODQ4NH0.vCtepj8M4Me9fYCWf-Z0n2_siaaLuBPmfWv1abHQ3ko',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
