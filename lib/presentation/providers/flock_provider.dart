import 'package:flutter/foundation.dart';
import '../../data/models/FlockModel.dart';
import '../../domain/entities/flock.dart';
import '../../domain/repositories/flock_repository.dart';

class FlockProvider with ChangeNotifier {
  final FlockRepository repository;
  List<Flock> _flocks = [];
  bool _isLoading = false;
  String _error = '';

  FlockProvider(this.repository);

  List<Flock> get flocks => _flocks;
  bool get isLoading => _isLoading;
  String get error => _error;
  List<Flock> get activeFlocks => _flocks.where((flock) => flock.status == 'active').toList();

  Future<void> loadFlocks() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _flocks = await repository.getAllFlocks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addFlock(String name, String batchNumber, String birdType,
      int birdCount, DateTime startDate) async {
    try {
      final newFlock = FlockModel(
        // تأكد من أن id هو null
        id: null,
        name: name,
        batchNumber: batchNumber,
        birdType: birdType,
        birdCount: birdCount,
        startDate: startDate,
        status: 'active',
        // تأكد من أن endDate هو null
        endDate: null,
      );

      print("Creating new flock: ${newFlock.toJson()}"); // للتصحيح

      final id = await repository.addFlock(newFlock);
      print("New flock ID: $id"); // للتصحيح

      if (id > 0) {
        await loadFlocks();
        return true;
      }
      _error = "Failed to add flock: Invalid ID returned";
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      print("Error in addFlock: $_error"); // للتصحيح
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFlockStatus(int id, String status, [DateTime? endDate]) async {
    try {
      final flockIndex = _flocks.indexWhere((flock) => flock.id == id);
      if (flockIndex >= 0) {
        final flock = _flocks[flockIndex] as FlockModel;
        final updatedFlock = flock.copy(
          status: status,
          endDate: status == 'active' ? null : (endDate ?? DateTime.now()),
        );

        final result = await repository.updateFlock(updatedFlock as Flock);
        if (result > 0) {
          await loadFlocks();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFlock(int id) async {
    try {
      final result = await repository.deleteFlock(id);
      if (result > 0) {
        await loadFlocks();
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