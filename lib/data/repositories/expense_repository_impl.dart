import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/database_helper.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper dbHelper;

  ExpenseRepositoryImpl(this.dbHelper);

  @override
  Future<List<Expense>> getExpensesByFlockId(int flockId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      ExpenseModel.tableName,
      where: '${ExpenseModel.colFlockId} = ?',
      whereArgs: [flockId],
      orderBy: '${ExpenseModel.colDate} DESC',
    );

    // Make sure ExpenseModel is explicitly cast as Expense
    return result.map((json) {
      Expense expense = ExpenseModel.fromJson(json);
      return expense;
    }).toList();
  }

  @override
  Future<Expense> getExpenseById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      ExpenseModel.tableName,
      where: '${ExpenseModel.colId} = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return ExpenseModel.fromJson(result.first);
    } else {
      throw Exception('Expense with ID $id not found');
    }
  }

  @override
  Future<int> addExpense(Expense expense) async {
    final db = await dbHelper.database;
    final expenseModel = expense as ExpenseModel;
    return await db.insert(ExpenseModel.tableName, expenseModel.toJson());
  }

  @override
  Future<int> updateExpense(Expense expense) async {
    final db = await dbHelper.database;
    final expenseModel = expense as ExpenseModel;
    return await db.update(
      ExpenseModel.tableName,
      expenseModel.toJson(),
      where: '${ExpenseModel.colId} = ?',
      whereArgs: [expenseModel.id],
    );
  }

  @override
  Future<int> deleteExpense(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      ExpenseModel.tableName,
      where: '${ExpenseModel.colId} = ?',
      whereArgs: [id],
    );
  }
}