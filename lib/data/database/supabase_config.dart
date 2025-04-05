import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Valores padrão que serão substituídos pelas variáveis de ambiente
  static const String DEFAULT_URL = 'https://mmbknnxfgwjgcvanagfe.supabase.co';
  static const String DEFAULT_ANON_KEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1tYmtubnhmZ3dqZ2N2YW5hZ2ZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4MDU5NDMsImV4cCI6MjA1OTM4MTk0M30.C1ZmJ9pUJOIiq5IPUzGmVEH08W2DyAlYh9rhsWbmM0A';

  // Getters para obter os valores das variáveis de ambiente ou usar os valores padrão
  static String get supabaseUrl => DEFAULT_URL;
  static String get supabaseAnonKey => DEFAULT_ANON_KEY;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}
