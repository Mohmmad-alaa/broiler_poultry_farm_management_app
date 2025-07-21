import '../../domain/entities/daily_record.dart';

class DailyRecordModel implements DailyRecord {
  final int? id;
  final int flockId;
  final DateTime date;
  final int mortality;
  final double weight;
  final double feedConsumption;
  final String notes;

  static const String tableName = 'daily_records';
  static const String colId = 'id';
  static const String colFlockId = 'flock_id';
  static const String colDate = 'date';
  static const String colMortality = 'mortality';
  static const String colWeight = 'weight';
  static const String colFeedConsumption = 'feed_consumption';
  static const String colNotes = 'notes';

  DailyRecordModel({
    this.id,
    required this.flockId,
    required this.date,
    required this.mortality,
    required this.weight,
    required this.feedConsumption,
    required this.notes,
  });

  DailyRecordModel copy({
    int? id,
    int? flockId,
    DateTime? date,
    int? mortality,
    double? weight,
    double? feedConsumption,
    String? notes,
  }) =>
      DailyRecordModel(
        id: id ?? this.id,
        flockId: flockId ?? this.flockId,
        date: date ?? this.date,
        mortality: mortality ?? this.mortality,
        weight: weight ?? this.weight,
        feedConsumption: feedConsumption ?? this.feedConsumption,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      colFlockId: flockId,
      colDate: date.toIso8601String(),
      colMortality: mortality,
      colWeight: weight,
      colFeedConsumption: feedConsumption,
      colNotes: notes,
    };

    if (id != null) {
      map[colId] = id;
    }

    return map;
  }

  static DailyRecordModel fromJson(Map<String, dynamic> json) => DailyRecordModel(
    id: json[colId],
    flockId: json[colFlockId],
    date: DateTime.parse(json[colDate]),
    mortality: json[colMortality],
    weight: json[colWeight],
    feedConsumption: json[colFeedConsumption],
    notes: json[colNotes],
  );
}