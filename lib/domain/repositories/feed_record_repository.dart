import '../entities/feed_record.dart';

abstract class FeedRecordRepository {
  Future<List<FeedRecord>> getFeedRecordsByFlockId(int flockId);
  Future<FeedRecord> getFeedRecordById(int id);
  Future<int> addFeedRecord(FeedRecord record);
  Future<int> updateFeedRecord(FeedRecord record);
  Future<int> deleteFeedRecord(int id);
}