import '../../domain/entities/feed_record.dart';

class FeedRecordModel implements FeedRecord {
  final int? id;
  final int flockId;
  final DateTime date;
  final String feedType;
  final double quantity;
  final double cost;

  static const String tableName = 'feed_records';
  static const String colId = 'id';
  static const String colFlockId = 'flock_id';
  static const String colDate = 'date';
  static const String colFeedType = 'feed_type';
  static const String colQuantity = 'quantity';
  static const String colCost = 'cost';

  FeedRecordModel({
    this.id,
    required this.flockId,
    required this.date,
    required this.feedType,
    required this.quantity,
    required this.cost,
  });

  FeedRecordModel copy({
    int? id,
    int? flockId,
    DateTime? date,
    String? feedType,
    double? quantity,
    double? cost,
  }) =>
      FeedRecordModel(
        id: id ?? this.id,
        flockId: flockId ?? this.flockId,
        date: date ?? this.date,
        feedType: feedType ?? this.feedType,
        quantity: quantity ?? this.quantity,
        cost: cost ?? this.cost,
      );

  Map<String, dynamic> toJson() => {
    colId: id,
    colFlockId: flockId,
    colDate: date.toIso8601String(),
    colFeedType: feedType,
    colQuantity: quantity,
    colCost: cost,
  };

  static FeedRecordModel fromJson(Map<String, dynamic> json) => FeedRecordModel(
    id: json[colId],
    flockId: json[colFlockId],
    date: DateTime.parse(json[colDate]),
    feedType: json[colFeedType],
    quantity: json[colQuantity],
    cost: json[colCost],
  );
}