import '../../domain/entities/daily_record.dart';
import '../../domain/repositories/daily_record_repository.dart';
import '../datasources/database_helper.dart';
import '../models/daily_record_model.dart';

class DailyRecordRepositoryImpl implements DailyRecordRepository {
  final DatabaseHelper dbHelper;

  DailyRecordRepositoryImpl(this.dbHelper);

  @override
  Future<List<DailyRecord>> getDailyRecordsByFlockId(int flockId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      DailyRecordModel.tableName,
      where: '${DailyRecordModel.colFlockId} = ?',
      whereArgs: [flockId],
      orderBy: '${DailyRecordModel.colDate} DESC',
    );

    List<DailyRecord> records = result.map((json) {
      DailyRecord record = DailyRecordModel.fromJson(json);
      return record;
    }).toList();

    return records;
  }

  @override
  Future<DailyRecord?> getDailyRecordByDate(int flockId, DateTime date) async {
    final db = await dbHelper.database;
    final dateString = date.toIso8601String().split('T')[0];

    final result = await db.query(
      DailyRecordModel.tableName,
      where: '${DailyRecordModel.colFlockId} = ? AND ${DailyRecordModel.colDate} LIKE ?',
      whereArgs: [flockId, '$dateString%'],
    );

    if (result.isNotEmpty) {
      return DailyRecordModel.fromJson(result.first);
    }
    return null;
  }

  @override
  Future<int> addDailyRecord(DailyRecord record) async {
    final db = await dbHelper.database;
    final recordModel = record as DailyRecordModel;
    return await db.insert(DailyRecordModel.tableName, recordModel.toJson());
  }

  @override
  Future<int> updateDailyRecord(DailyRecord record) async {
    final db = await dbHelper.database;
    final recordModel = record as DailyRecordModel;
    return await db.update(
      DailyRecordModel.tableName,
      recordModel.toJson(),
      where: '${DailyRecordModel.colId} = ?',
      whereArgs: [recordModel.id],
    );
  }

  @override
  Future<int> deleteDailyRecord(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      DailyRecordModel.tableName,
      where: '${DailyRecordModel.colId} = ?',
      whereArgs: [id],
    );
  }
}