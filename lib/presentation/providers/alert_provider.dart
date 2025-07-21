import 'package:flutter/foundation.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../data/models/alert_model.dart';

class AlertProvider with ChangeNotifier {
  final AlertRepository repository;
  List<Alert> _alerts = [];
  bool _isLoading = false;
  String _error = '';

  AlertProvider(this.repository);

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadAlertsByFlockId(int flockId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _alerts = await repository.getAlertsByFlockId(flockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAllActiveAlerts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _alerts = await repository.getAllActiveAlerts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addAlert(int flockId, String title, String description,
      DateTime dueDate, String priority) async {
    try {
      final newAlert = AlertModel(
        flockId: flockId,
        title: title,
        description: description,
        dueDate: dueDate,
        isCompleted: false,
        priority: priority,
      );

      final id = await repository.addAlert(newAlert);
      if (id > 0) {
        await loadAllActiveAlerts();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAlert(int id, int flockId, String title,
      String description, DateTime dueDate, bool isCompleted, String priority) async {
    try {
      final updatedAlert = AlertModel(
        id: id,
        flockId: flockId,
        title: title,
        description: description,
        dueDate: dueDate,
        isCompleted: isCompleted,
        priority: priority,
      );

      final result = await repository.updateAlert(updatedAlert);
      if (result > 0) {
        await loadAllActiveAlerts();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAlert(int id) async {
    try {
      final result = await repository.deleteAlert(id);
      if (result > 0) {
        await loadAllActiveAlerts();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAlertAsCompleted(int id) async {
    try {
      final result = await repository.markAlertAsCompleted(id);
      if (result > 0) {
        await loadAllActiveAlerts();
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