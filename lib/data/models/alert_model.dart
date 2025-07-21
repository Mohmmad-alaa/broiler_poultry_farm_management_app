import '../../domain/entities/alert.dart';

class AlertModel implements Alert {
  final int? id;
  final int flockId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String priority; // high, medium, low

  static const String tableName = 'alerts';
  static const String colId = 'id';
  static const String colFlockId = 'flock_id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colDueDate = 'due_date';
  static const String colIsCompleted = 'is_completed';
  static const String colPriority = 'priority';

  AlertModel({
    this.id,
    required this.flockId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.priority,
  });

  AlertModel copy({
    int? id,
    int? flockId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? priority,
  }) =>
      AlertModel(
        id: id ?? this.id,
        flockId: flockId ?? this.flockId,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        isCompleted: isCompleted ?? this.isCompleted,
        priority: priority ?? this.priority,
      );

  Map<String, dynamic> toJson() => {
        colFlockId: flockId,
        colTitle: title,
        colDescription: description,
        colDueDate: dueDate.toIso8601String(),
        colIsCompleted: isCompleted ? 1 : 0,
        colPriority: priority,
        if (id != null) colId: id,
      };

  static AlertModel fromJson(Map<String, dynamic> json) => AlertModel(
        id: json[colId],
        flockId: json[colFlockId],
        title: json[colTitle],
        description: json[colDescription],
        dueDate: DateTime.parse(json[colDueDate]),
        isCompleted: json[colIsCompleted] == 1,
        priority: json[colPriority],
      );
}