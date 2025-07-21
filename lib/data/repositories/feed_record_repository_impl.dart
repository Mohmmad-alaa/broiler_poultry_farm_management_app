import '../../domain/entities/feed_record.dart';
import '../../domain/repositories/feed_record_repository.dart';
import '../datasources/database_helper.dart';
import '../models/feed_record_model.dart';

class FeedRecordRepositoryImpl implements FeedRecordRepository {
  final DatabaseHelper dbHelper;

  FeedRecordRepositoryImpl(this.dbHelper);

  @override
  Future<List<FeedRecord>> getFeedRecordsByFlockId(int flockId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      FeedRecordModel.tableName,
      where: '${FeedRecordModel.colFlockId} = ?',
      whereArgs: [flockId],
      orderBy: '${FeedRecordModel.colDate} DESC',
    );

    // Explicitly convert to List<FeedRecord>
    List<FeedRecord> records = result.map((json) {
      FeedRecord record = FeedRecordModel.fromJson(json);
      return record;
    }).toList();

    return records;
  }

  @override
  Future<FeedRecord> getFeedRecordById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      FeedRecordModel.tableName,
      where: '${FeedRecordModel.colId} = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return FeedRecordModel.fromJson(result.first);
    } else {
      throw Exception('Feed record with ID $id not found');
    }
  }

  @override
  Future<int> addFeedRecord(FeedRecord record) async {
    final db = await dbHelper.database;
    final recordModel = record as FeedRecordModel;
    return await db.insert(FeedRecordModel.tableName, recordModel.toJson());
  }

  @override
  Future<int> updateFeedRecord(FeedRecord record) async {
    final db = await dbHelper.database;
    final recordModel = record as FeedRecordModel;
    return await db.update(
      FeedRecordModel.tableName,
      recordModel.toJson(),
      where: '${FeedRecordModel.colId} = ?',
      whereArgs: [recordModel.id],
    );
  }

  @override
  Future<int> deleteFeedRecord(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      FeedRecordModel.tableName,
      where: '${FeedRecordModel.colId} = ?',
      whereArgs: [id],
    );
  }
}