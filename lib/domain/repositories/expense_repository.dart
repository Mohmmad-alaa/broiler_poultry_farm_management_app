import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpensesByFlockId(int flockId);
  Future<Expense> getExpenseById(int id);
  Future<int> addExpense(Expense expense);
  Future<int> updateExpense(Expense expense);
  Future<int> deleteExpense(int id);
}