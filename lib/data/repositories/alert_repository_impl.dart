import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/database_helper.dart';
import '../models/alert_model.dart';

class AlertRepositoryImpl implements AlertRepository {
  final DatabaseHelper dbHelper;

  AlertRepositoryImpl(this.dbHelper);

  @override
  Future<List<Alert>> getAlertsByFlockId(int flockId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      AlertModel.tableName,
      where: '${AlertModel.colFlockId} = ?',
      whereArgs: [flockId],
      orderBy: '${AlertModel.colDueDate} ASC',
    );

    List<Alert> alerts = result.map((json) {
      Alert alert = AlertModel.fromJson(json);
      return alert;
    }).toList();

    return alerts;
  }

  @override
  Future<List<Alert>> getAllActiveAlerts() async {
    final db = await dbHelper.database;
    final result = await db.query(
      AlertModel.tableName,
      where: '${AlertModel.colIsCompleted} = ?',
      whereArgs: [0], // 0 means false (not completed)
      orderBy: '${AlertModel.colDueDate} ASC',
    );

    List<Alert> alerts = result.map((json) {
      Alert alert = AlertModel.fromJson(json);
      return alert;
    }).toList();

    return alerts;
  }

  @override
  Future<Alert> getAlertById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      AlertModel.tableName,
      where: '${AlertModel.colId} = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return AlertModel.fromJson(result.first);
    } else {
      throw Exception('Alert with ID $id not found');
    }
  }

  @override
  Future<int> addAlert(Alert alert) async {
    final db = await dbHelper.database;
    final alertModel = alert as AlertModel;
    return await db.insert(AlertModel.tableName, alertModel.toJson());
  }

  @override
  Future<int> updateAlert(Alert alert) async {
    final db = await dbHelper.database;
    final alertModel = alert as AlertModel;
    return await db.update(
      AlertModel.tableName,
      alertModel.toJson(),
      where: '${AlertModel.colId} = ?',
      whereArgs: [alertModel.id],
    );
  }

  @override
  Future<int> deleteAlert(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      AlertModel.tableName,
      where: '${AlertModel.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> markAlertAsCompleted(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      AlertModel.tableName,
      {AlertModel.colIsCompleted: 1},
      where: '${AlertModel.colId} = ?',
      whereArgs: [id],
    );
  }
}