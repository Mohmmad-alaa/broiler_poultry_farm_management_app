import '../entities/flock.dart';

abstract class FlockRepository {
  Future<List<Flock>> getAllFlocks();
  Future<Flock> getFlockById(int id);
  Future<int> addFlock(Flock flock);
  Future<int> updateFlock(Flock flock);
  Future<int> deleteFlock(int id);
  Future<List<Flock>> getActiveFlocks();
}