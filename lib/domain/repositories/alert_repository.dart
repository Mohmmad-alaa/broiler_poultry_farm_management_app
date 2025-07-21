import '../entities/alert.dart';

abstract class AlertRepository {
  Future<List<Alert>> getAlertsByFlockId(int flockId);
  Future<List<Alert>> getAllActiveAlerts();
  Future<Alert> getAlertById(int id);
  Future<int> addAlert(Alert alert);
  Future<int> updateAlert(Alert alert);
  Future<int> deleteAlert(int id);
  Future<int> markAlertAsCompleted(int id);
}