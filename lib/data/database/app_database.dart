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
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adicionar tabela de sincronização se estiver atualizando para a versão 2
      await _createSyncStatusTable(db);
    }
    if (oldVersion < 3) {
      // Adicionar tabela de autenticação se estiver atualizando para a versão 3
      await _createAuthTable(db);
    }
    if (oldVersion < 4) {
      // Adicionar tabela de fazendas se estiver atualizando para a versão 4
      await _createFarmTable(db);
    }
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
        notes TEXT,
        farm_id TEXT
      )
    ''');

    // Criar tabela de colaboradores
    await db.execute('''
      CREATE TABLE collaborators(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        daily_rate REAL NOT NULL,
        farm_id TEXT
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
        farm_id TEXT,
        FOREIGN KEY (collaborator_id) REFERENCES collaborators(id)
      )
    ''');

    // Criar tabela de status de sincronização
    await _createSyncStatusTable(db);

    // Criar tabela de autenticação
    await _createAuthTable(db);

    // Criar tabela de fazendas
    await _createFarmTable(db);
  }

  Future<void> _createSyncStatusTable(Database db) async {
    await db.execute('''
      CREATE TABLE sync_status(
        entity_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        state TEXT NOT NULL,
        last_sync_time TEXT NOT NULL,
        last_local_update TEXT NOT NULL,
        version INTEGER NOT NULL,
        PRIMARY KEY (entity_id, entity_type)
      )
    ''');
  }

  Future<void> _createAuthTable(Database db) async {
    await db.execute('''
      CREATE TABLE auth(
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        token TEXT,
        expires_at TEXT
      )
    ''');
  }

  Future<void> _createFarmTable(Database db) async {
    await db.execute('''
      CREATE TABLE farms(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT,
        user_id TEXT NOT NULL,
        description TEXT,
        total_area REAL,
        main_crop TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
}
