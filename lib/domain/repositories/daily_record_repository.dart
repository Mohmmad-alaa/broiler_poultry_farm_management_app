import '../entities/daily_record.dart';

abstract class DailyRecordRepository {
  Future<List<DailyRecord>> getDailyRecordsByFlockId(int flockId);
  Future<DailyRecord?> getDailyRecordByDate(int flockId, DateTime date);
  Future<int> addDailyRecord(DailyRecord record);
  Future<int> updateDailyRecord(DailyRecord record);
  Future<int> deleteDailyRecord(int id);
}