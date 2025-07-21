import '../../domain/entities/expense.dart';

class ExpenseModel implements Expense {
  final int? id;
  final int flockId;
  final DateTime date;
  final String category;
  final String description;
  final double amount;

  static const String tableName = 'expenses';
  static const String colId = 'id';
  static const String colFlockId = 'flock_id';
  static const String colDate = 'date';
  static const String colCategory = 'category';
  static const String colDescription = 'description';
  static const String colAmount = 'amount';

  ExpenseModel({
    this.id,
    required this.flockId,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
  });

  ExpenseModel copy({
    int? id,
    int? flockId,
    DateTime? date,
    String? category,
    String? description,
    double? amount,
  }) =>
      ExpenseModel(
        id: id ?? this.id,
        flockId: flockId ?? this.flockId,
        date: date ?? this.date,
        category: category ?? this.category,
        description: description ?? this.description,
        amount: amount ?? this.amount,
      );

  Map<String, dynamic> toJson() => {
    colId: id,
    colFlockId: flockId,
    colDate: date.toIso8601String(),
    colCategory: category,
    colDescription: description,
    colAmount: amount,
  };

  static ExpenseModel fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json[colId],
    flockId: json[colFlockId],
    date: DateTime.parse(json[colDate]),
    category: json[colCategory],
    description: json[colDescription],
    amount: json[colAmount],
  );
}