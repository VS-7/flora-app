import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flora_app.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // Criar tabela de usuários
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        farm_name TEXT NOT NULL,
        location TEXT
      )
    ''');

    // Criar tabela de atividades
    await db.execute('''
      CREATE TABLE activities(
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        cost REAL,
        area_in_hectares REAL,
        quantity_in_bags INTEGER,
        notes TEXT
      )
    ''');

    // Criar tabela de colaboradores
    await db.execute('''
      CREATE TABLE collaborators(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        daily_rate REAL NOT NULL
      )
    ''');

    // Criar tabela de pagamentos
    await db.execute('''
      CREATE TABLE payments(
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        collaborator_id TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (collaborator_id) REFERENCES collaborators(id)
      )
    ''');
  }
}
