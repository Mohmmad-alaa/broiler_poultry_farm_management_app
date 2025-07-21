
import '../entities/health_record.dart';

abstract class HealthRecordRepository {
  Future<List<HealthRecord>> getHealthRecordsByFlockId(int flockId);
  Future<HealthRecord> getHealthRecordById(int id);
  Future<int> addHealthRecord(HealthRecord record);
  Future<int> updateHealthRecord(HealthRecord record);
  Future<int> deleteHealthRecord(int id);
}