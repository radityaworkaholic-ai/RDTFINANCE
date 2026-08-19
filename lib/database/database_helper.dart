import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'rdtfinance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            amount REAL NOT NULL,
            isIncome INTEGER NOT NULL,
            payment TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertTransaction({
    required String description,
    required double amount,
    required bool isIncome,
    required String payment,
  }) async {
    final db = await database;

    final id = await db.insert(
      'transactions',
      {
        'description': description,
        'amount': amount,
        'isIncome': isIncome ? 1 : 0,
        'payment': payment,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );

    return id;
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    final result = await db.query(
      'transactions',
      orderBy: 'createdAt DESC',
    );

    return result;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTransactionCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}