import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/FlockModel.dart';
import '../models/daily_record_model.dart';
import '../models/feed_record_model.dart';
import '../models/health_record_model.dart';
import '../models/expense_model.dart';
import '../models/alert_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('poultry_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // زيادة رقم الإصدار من 1 إلى 2
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }
  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'poultry_manager.db');
    _database = await openDatabase(
      path,
      version: 2, // زيادة رقم الإصدار من 1 إلى 2
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  // أضف دالة _onUpgrade
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إنشاء جدول التنبيهات إذا كان الإصدار القديم أقل من 2
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';
      
      // Alerts table
      await db.execute('''
      CREATE TABLE ${AlertModel.tableName} (
        ${AlertModel.colId} $idType,
        ${AlertModel.colFlockId} $intType,
        ${AlertModel.colTitle} $textType,
        ${AlertModel.colDescription} $textType,
        ${AlertModel.colDueDate} $textType,
        ${AlertModel.colIsCompleted} INTEGER NOT NULL,
        ${AlertModel.colPriority} $textType
      )
      ''');
    }
  }
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Flocks table
    await db.execute('''
    CREATE TABLE flocks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      batch_number TEXT NOT NULL,
      bird_type TEXT NOT NULL,
      bird_count INTEGER NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT NULL,
      status TEXT NOT NULL
    )
  ''');

    // Feed records table
    await db.execute('''
    CREATE TABLE ${FeedRecordModel.tableName} (
      ${FeedRecordModel.colId} $idType,
      ${FeedRecordModel.colFlockId} $intType,
      ${FeedRecordModel.colDate} $textType,
      ${FeedRecordModel.colFeedType} $textType,
      ${FeedRecordModel.colQuantity} $realType,
      ${FeedRecordModel.colCost} $realType
    )
    ''');

    // Health records table
    await db.execute('''
    CREATE TABLE ${HealthRecordModel.tableName} (
      ${HealthRecordModel.colId} $idType,
      ${HealthRecordModel.colFlockId} $intType,
      ${HealthRecordModel.colDate} $textType,
      ${HealthRecordModel.colType} $textType,
      ${HealthRecordModel.colDescription} $textType,
      ${HealthRecordModel.colMedication} $textType,
      ${HealthRecordModel.colCost} $realType
    )
    ''');

    // Expenses table
    await db.execute('''
    CREATE TABLE ${ExpenseModel.tableName} (
      ${ExpenseModel.colId} $idType,
      ${ExpenseModel.colFlockId} $intType,
      ${ExpenseModel.colDate} $textType,
      ${ExpenseModel.colCategory} $textType,
      ${ExpenseModel.colDescription} $textType,
      ${ExpenseModel.colAmount} $realType
    )
    ''');

    // Create daily_records table
    await db.execute('''
    CREATE TABLE daily_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      flock_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      mortality INTEGER NOT NULL,
      weight REAL NOT NULL,
      feed_consumption REAL NOT NULL,
      notes TEXT NOT NULL,
      FOREIGN KEY (flock_id) REFERENCES flocks (id) ON DELETE CASCADE
    )
  ''');

 
    
    // في دالة _createDB، أضف هذا الكود بعد إنشاء الجداول الأخرى
    
    // Alerts table
    await db.execute('''
    CREATE TABLE ${AlertModel.tableName} (
      ${AlertModel.colId} $idType,
      ${AlertModel.colFlockId} $intType,
      ${AlertModel.colTitle} $textType,
      ${AlertModel.colDescription} $textType,
      ${AlertModel.colDueDate} $textType,
      ${AlertModel.colIsCompleted} INTEGER NOT NULL,
      ${AlertModel.colPriority} $textType
    )
    ''');
  }

  // Database operations will be added here

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), 'poultry_manager.db');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

}