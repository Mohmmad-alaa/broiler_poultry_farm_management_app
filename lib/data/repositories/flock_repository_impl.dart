import '../../domain/entities/flock.dart';
import '../../domain/repositories/flock_repository.dart';
import '../datasources/database_helper.dart';
import '../models/FlockModel.dart';

class FlockRepositoryImpl implements FlockRepository {
  final DatabaseHelper dbHelper;

  FlockRepositoryImpl(this.dbHelper);

  @override
  Future<List<Flock>> getAllFlocks() async {
    final db = await dbHelper.database;
    final result = await db.query(FlockModel.tableName);
    return result.map((json) => FlockModel.fromJson(json)).toList();
  }

  @override
  Future<Flock> getFlockById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      FlockModel.tableName,
      where: '${FlockModel.colId} = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return FlockModel.fromJson(result.first);
    } else {
      throw Exception('Flock with ID $id not found');
    }
  }

  @override
  Future<int> addFlock(Flock flock) async {
    try {
      final db = await dbHelper.database;
      final flockModel = flock as FlockModel;

      // تأكد من أن البيانات صحيحة قبل الإدخال
      final data = flockModel.toJson();
      print("Inserting flock data: $data"); // للتصحيح

      return await db.insert(FlockModel.tableName, data);
    } catch (e) {
      print("Error adding flock: $e"); // للتصحيح
      throw Exception("Failed to add flock: $e");
    }
  }

  @override
  Future<int> updateFlock(Flock flock) async {
    final db = await dbHelper.database;
    final flockModel = flock as FlockModel;
    return await db.update(
      FlockModel.tableName,
      flockModel.toJson(),
      where: '${FlockModel.colId} = ?',
      whereArgs: [flockModel.id],
    );
  }

  @override
  Future<int> deleteFlock(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      FlockModel.tableName,
      where: '${FlockModel.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Flock>> getActiveFlocks() async {
    final db = await dbHelper.database;
    final result = await db.query(
      FlockModel.tableName,
      where: '${FlockModel.colStatus} = ?',
      whereArgs: ['active'],
    );
    return result.map((json) => FlockModel.fromJson(json)).toList();
  }
}