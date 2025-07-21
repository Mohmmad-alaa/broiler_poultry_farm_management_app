abstract class Alert {
  int? get id;
  int get flockId;
  String get title;
  String get description;
  DateTime get dueDate;
  bool get isCompleted;
  String get priority; // high, medium, low
}