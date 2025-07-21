import 'package:flutter/foundation.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/repositories/health_record_repository.dart';
import '../../data/models/health_record_model.dart';

class HealthRecordProvider with ChangeNotifier {
  final HealthRecordRepository repository;
  List<HealthRecord> _healthRecords = [];
  bool _isLoading = false;
  String _error = '';

  HealthRecordProvider(this.repository);

  List<HealthRecord> get healthRecords => _healthRecords;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadHealthRecords(int flockId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _healthRecords = await repository.getHealthRecordsByFlockId(flockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addHealthRecord(int flockId, DateTime date, String type,
      String description, String medication, double cost) async {
    try {
      final newRecord = HealthRecordModel(
        flockId: flockId,
        date: date,
        type: type,
        description: description,
        medication: medication,
        cost: cost,
      );

      final id = await repository.addHealthRecord(newRecord as HealthRecord);
      if (id > 0) {
        await loadHealthRecords(flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
// Add this method to your HealthRecordProvider class
  Future<void> loadHealthRecordsByFlockId(int flockId) async {
    String? _error;
    _error = null;
    notifyListeners();

    try {
      _healthRecords = await repository.getHealthRecordsByFlockId(flockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  Future<bool> deleteHealthRecord(int id, int flockId) async {
    try {
      final result = await repository.deleteHealthRecord(id);
      if (result > 0) {
        await loadHealthRecords(flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  double getTotalHealthCost() {
    return _healthRecords.fold(0, (sum, record) => sum + record.cost);
  }
}