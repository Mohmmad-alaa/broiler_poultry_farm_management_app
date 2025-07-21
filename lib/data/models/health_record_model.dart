import '../../domain/entities/health_record.dart';

class HealthRecordModel implements HealthRecord {
  final int? id;
  final int flockId;
  final DateTime date;
  final String type; // vaccination, medication, observation
  final String description;
  final String medication;
  final double cost;

  static const String tableName = 'health_records';
  static const String colId = 'id';
  static const String colFlockId = 'flock_id';
  static const String colDate = 'date';
  static const String colType = 'type';
  static const String colDescription = 'description';
  static const String colMedication = 'medication';
  static const String colCost = 'cost';

  HealthRecordModel({
    this.id,
    required this.flockId,
    required this.date,
    required this.type,
    required this.description,
    required this.medication,
    required this.cost,
  });

  HealthRecordModel copy({
    int? id,
    int? flockId,
    DateTime? date,
    String? type,
    String? description,
    String? medication,
    double? cost,
  }) =>
      HealthRecordModel(
        id: id ?? this.id,
        flockId: flockId ?? this.flockId,
        date: date ?? this.date,
        type: type ?? this.type,
        description: description ?? this.description,
        medication: medication ?? this.medication,
        cost: cost ?? this.cost,
      );

  Map<String, dynamic> toJson() => {
    colId: id,
    colFlockId: flockId,
    colDate: date.toIso8601String(),
    colType: type,
    colDescription: description,
    colMedication: medication,
    colCost: cost,
  };

  static HealthRecordModel fromJson(Map<String, dynamic> json) => HealthRecordModel(
    id: json[colId],
    flockId: json[colFlockId],
    date: DateTime.parse(json[colDate]),
    type: json[colType],
    description: json[colDescription],
    medication: json[colMedication],
    cost: json[colCost],
  );
}