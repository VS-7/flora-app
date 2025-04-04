import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Salvar dados no armazenamento local
  Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(value);
    await prefs.setString(key, jsonString);
  }

  // Recuperar dados do armazenamento local
  Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);

    if (jsonString == null) {
      return null;
    }

    return json.decode(jsonString);
  }

  // Remover dados do armazenamento local
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Verificar se existe dados para uma chave especu00edfica
  Future<bool> hasData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  // Limpar todos os dados do armazenamento local
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
