import '../interfaces/entity.dart';

enum ActivityType {
  planting,
  irrigation,
  fertilization,
  pestControl,
  pruning,
  harvesting,
  maintenance,
  other,
}

class FarmActivity implements Entity {
  @override
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final ActivityType type;
  final String farmId;
  final String?
  talhaoId; // Optional, as not all activities may be tied to a specific talhão
  final String? harvestId; // Reference to yearly harvest
  final String? employeeId; // Optional, the employee responsible
  final List<String>? productIds; // Optional, products used in this activity
  final DateTime createdAt;
  final DateTime updatedAt;

  FarmActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.farmId,
    this.talhaoId,
    this.harvestId,
    this.employeeId,
    this.productIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmActivity.fromMap(Map<String, dynamic> map) {
    return FarmActivity(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: ActivityType.values.byName(map['type']),
      farmId: map['farm_id'],
      talhaoId: map['talhao_id'],
      harvestId: map['harvest_id'],
      employeeId: map['employee_id'],
      productIds:
          map['product_ids'] != null
              ? List<String>.from(map['product_ids'])
              : null,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.name,
      'farm_id': farmId,
      'talhao_id': talhaoId,
      'harvest_id': harvestId,
      'employee_id': employeeId,
      'product_ids': productIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FarmActivity copyWith({
    String? title,
    String? description,
    DateTime? date,
    ActivityType? type,
    String? talhaoId,
    String? harvestId,
    String? employeeId,
    List<String>? productIds,
  }) {
    return FarmActivity(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      farmId: this.farmId,
      talhaoId: talhaoId ?? this.talhaoId,
      harvestId: harvestId ?? this.harvestId,
      employeeId: employeeId ?? this.employeeId,
      productIds: productIds ?? this.productIds,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
