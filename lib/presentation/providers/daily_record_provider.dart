import 'package:flutter/foundation.dart';
import '../../domain/entities/daily_record.dart';
import '../../domain/repositories/daily_record_repository.dart';
import '../../data/models/daily_record_model.dart';

class DailyRecordProvider with ChangeNotifier {
  final DailyRecordRepository repository;

  List<DailyRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  DailyRecordProvider(this.repository);

  List<DailyRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDailyRecords(int flockId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await repository.getDailyRecordsByFlockId(flockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addDailyRecord(
      int flockId,
      DateTime date,
      int mortality,
      double weight,
      double feedConsumption,
      String notes,
      ) async {
    try {
      // التحقق مما إذا كان هناك سجل موجود بالفعل لهذا التاريخ
      final existingRecord = await repository.getDailyRecordByDate(flockId, date);
      if (existingRecord != null) {
        _error = 'يوجد سجل بالفعل لهذا التاريخ';
        notifyListeners();
        return false;
      }

      final newRecord = DailyRecordModel(
        flockId: flockId,
        date: date,
        mortality: mortality,
        weight: weight,
        feedConsumption: feedConsumption,
        notes: notes,
      );

      final id = await repository.addDailyRecord(newRecord);
      if (id > 0) {
        await loadDailyRecords(flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDailyRecord(DailyRecord record) async {
    try {
      final result = await repository.updateDailyRecord(record);
      if (result > 0) {
        await loadDailyRecords(record.flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDailyRecord(int id, int flockId) async {
    try {
      final result = await repository.deleteDailyRecord(id);
      if (result > 0) {
        await loadDailyRecords(flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}