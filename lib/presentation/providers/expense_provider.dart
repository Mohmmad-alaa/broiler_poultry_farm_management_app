import 'package:flutter/foundation.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository repository;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String _error = '';

  ExpenseProvider(this.repository);

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadExpenses(int flockId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _expenses = await repository.getExpensesByFlockId(flockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add this method to your ExpenseProvider class
  Future<void> loadExpensesByFlockId(int flockId) async {
    _isLoading = true;
    String? _error;
    _error = null;
    notifyListeners();

    try {
      _expenses = await repository.getExpensesByFlockId(flockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addExpense(int flockId, DateTime date, String category,
      String description, double amount) async {
    try {
      final newExpense = ExpenseModel(
        flockId: flockId,
        date: date,
        category: category,
        description: description,
        amount: amount,
      );

      final id = await repository.addExpense(newExpense as Expense);
      if (id > 0) {
        await loadExpenses(flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(int id, int flockId) async {
    try {
      final result = await repository.deleteExpense(id);
      if (result > 0) {
        await loadExpenses(flockId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  double getTotalExpenseCost() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getExpensesByCategory() {
    final Map<String, double> result = {};
    for (final expense in _expenses) {
      if (result.containsKey(expense.category)) {
        result[expense.category] = result[expense.category]! + expense.amount;
      } else {
        result[expense.category] = expense.amount;
      }
    }
    return result;
  }
}