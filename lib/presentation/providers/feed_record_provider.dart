import 'package:flutter/foundation.dart';
import '../../domain/entities/feed_record.dart';
import '../../domain/repositories/feed_record_repository.dart';
import '../../data/models/feed_record_model.dart';

class FeedRecordProvider with ChangeNotifier {
  final FeedRecordRepository repository;
  List<FeedRecord> _feedRecords = [];
  bool _isLoading = false;
  String _error = '';

  FeedRecordProvider(this.repository);

  List<FeedRecord> get feedRecords => _feedRecords;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadFeedRecords(int flockId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _feedRecords = await repository.getFeedRecordsByFlockId(flockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addFeedRecord(int flockId, DateTime date, String feedType,
      double quantity, double cost) async {
    try {
      final newRecord = FeedRecordModel(
        flockId: flockId,
        date: date,
        feedType: feedType,
        quantity: quantity,
        cost: cost,
      );

      final id = await repository.addFeedRecord(newRecord as FeedRecord);
      if (id > 0) {
        await loadFeedRecords(flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
// Add this method to your FeedRecordProvider class
  Future<void> loadFeedRecordsByFlockId(int flockId) async {
    _isLoading = true;
    String? _error;
    _error = null;
    notifyListeners();

    try {
      _feedRecords = await repository.getFeedRecordsByFlockId(flockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  Future<bool> updateFeedRecord(FeedRecord record) async {
    try {
      final result = await repository.updateFeedRecord(record);
      if (result > 0) {
        await loadFeedRecords(record.flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFeedRecord(int id, int flockId) async {
    try {
      final result = await repository.deleteFeedRecord(id);
      if (result > 0) {
        await loadFeedRecords(flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  double getTotalFeedQuantity() {
    return _feedRecords.fold(0, (sum, record) => sum + record.quantity);
  }

  double getTotalFeedCost() {
    return _feedRecords.fold(0, (sum, record) => sum + record.cost);
  }
}