import '../../domain/entities/health_record.dart';
import '../../domain/repositories/health_record_repository.dart';
import '../datasources/database_helper.dart';
import '../models/health_record_model.dart';

class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final DatabaseHelper dbHelper;

  HealthRecordRepositoryImpl(this.dbHelper);

  @override
  Future<List<HealthRecord>> getHealthRecordsByFlockId(int flockId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      HealthRecordModel.tableName,
      where: '${HealthRecordModel.colFlockId} = ?',
      whereArgs: [flockId],
      orderBy: '${HealthRecordModel.colDate} DESC',
    );

    // Explicitly convert to List<HealthRecord>
    List<HealthRecord> records = result.map((json) {
      HealthRecord record = HealthRecordModel.fromJson(json);
      return record;
    }).toList();

    return records;
  }

  @override
  Future<HealthRecord> getHealthRecordById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      HealthRecordModel.tableName,
      where: '${HealthRecordModel.colId} = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return HealthRecordModel.fromJson(result.first);
    } else {
      throw Exception('Health record with ID $id not found');
    }
  }

  @override
  Future<int> addHealthRecord(HealthRecord record) async {
    final db = await dbHelper.database;
    final recordModel = record as HealthRecordModel;
    return await db.insert(HealthRecordModel.tableName, recordModel.toJson());
  }

  @override
  Future<int> updateHealthRecord(HealthRecord record) async {
    final db = await dbHelper.database;
    final recordModel = record as HealthRecordModel;
    return await db.update(
      HealthRecordModel.tableName,
      recordModel.toJson(),
      where: '${HealthRecordModel.colId} = ?',
      whereArgs: [recordModel.id],
    );
  }

  @override
  Future<int> deleteHealthRecord(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      HealthRecordModel.tableName,
      where: '${HealthRecordModel.colId} = ?',
      whereArgs: [id],
    );
  }
}