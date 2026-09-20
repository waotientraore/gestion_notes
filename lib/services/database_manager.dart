import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/note.dart';

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Gère l'accès à la base de données SQLite de l'application.
class DatabaseManager {
  // Instance unique partagée dans toute l'app (pattern singleton).
  static final DatabaseManager instance = DatabaseManager._internal();
  DatabaseManager._internal();

  static Database? _database;

  // Retourne la base de données, en l'ouvrant si besoin.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Ouvre le fichier notes.db (le crée s'il n'existe pas encore).
  Future<Database> _initDatabase() async {
    // Sur le web, on utilise le moteur spécial "ffi_web".
    var factory = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;

    String path = kIsWeb
        ? 'notes.db'
        : join(await getDatabasesPath(), 'notes.db');

    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Requête SQL de création de la table.
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // Insère une nouvelle note et retourne son id généré.
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  // Récupère toutes les notes, triées par date de création décroissante.
  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Met à jour une note existante (identifiée par son id).
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Supprime une note grâce à son id.
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
