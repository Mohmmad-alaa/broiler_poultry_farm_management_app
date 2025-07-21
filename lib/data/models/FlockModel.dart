import '../../domain/entities/flock.dart';

class FlockModel implements Flock{
  final int? id;
  final String name;
  final String batchNumber;
  final DateTime startDate;
  final int birdCount;
  final String birdType;
  final String status; // active, completed, culled
  final DateTime? endDate;

  static const String tableName = 'flocks';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colBatchNumber = 'batch_number';
  static const String colStartDate = 'start_date';
  static const String colBirdCount = 'bird_count';
  static const String colBirdType = 'bird_type';
  static const String colStatus = 'status';
  static const String colEndDate = 'end_date';

  FlockModel({
    this.id,
    required this.name,
    required this.batchNumber,
    required this.startDate,
    required this.birdCount,
    required this.birdType,
    required this.status,
    this.endDate,
  });

  FlockModel copy({
    int? id,
    String? name,
    String? batchNumber,
    DateTime? startDate,
    int? birdCount,
    String? birdType,
    String? status,
    DateTime? endDate,
  }) =>
      FlockModel(
        id: id ?? this.id,
        name: name ?? this.name,
        batchNumber: batchNumber ?? this.batchNumber,
        startDate: startDate ?? this.startDate,
        birdCount: birdCount ?? this.birdCount,
        birdType: birdType ?? this.birdType,
        status: status ?? this.status,
        endDate: endDate ?? this.endDate,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      colName: name,
      colBatchNumber: batchNumber,
      colBirdType: birdType,
      colBirdCount: birdCount,
      colStartDate: startDate.toIso8601String(),
      colStatus: status,
      // Always include end_date with a default empty string if null
      colEndDate: endDate?.toIso8601String() ?? '',
    };

    // Only add id if it's not null
    if (id != null) {
      map[colId] = id;
    }

    return map;
  }

  static FlockModel fromJson(Map<String, dynamic> json) => FlockModel(
    id: json[colId],
    name: json[colName],
    batchNumber: json[colBatchNumber],
    startDate: DateTime.parse(json[colStartDate]),
    birdCount: json[colBirdCount],
    birdType: json[colBirdType],
    status: json[colStatus],
    endDate: json[colEndDate] != null && json[colEndDate] != ''
        ? DateTime.parse(json[colEndDate])
        : null,
  );
}