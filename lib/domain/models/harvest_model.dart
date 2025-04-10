import '../interfaces/entity.dart';

class Harvest implements Entity {
  @override
  final String id;
  final DateTime startDate;
  final String coffeeType;
  final int totalQuantity;
  final int quality;
  final String? weather;
  final String talhaoId;
  final String farmId;
  final List<String>? usedProducts; // List of product IDs
  final DateTime createdAt;
  final DateTime updatedAt;

  Harvest({
    required this.id,
    required this.startDate,
    required this.coffeeType,
    required this.totalQuantity,
    required this.quality,
    this.weather,
    required this.talhaoId,
    required this.farmId,
    this.usedProducts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Harvest.fromMap(Map<String, dynamic> map) {
    return Harvest(
      id: map['id'],
      startDate: DateTime.parse(map['start_date']),
      coffeeType: map['coffee_type'],
      totalQuantity: map['total_quantity'],
      quality: map['quality'],
      weather: map['weather'],
      talhaoId: map['talhao_id'],
      farmId: map['farm_id'],
      usedProducts:
          map['used_products'] != null
              ? List<String>.from(map['used_products'])
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
      'start_date': startDate.toIso8601String(),
      'coffee_type': coffeeType,
      'total_quantity': totalQuantity,
      'quality': quality,
      'weather': weather,
      'talhao_id': talhaoId,
      'farm_id': farmId,
      'used_products': usedProducts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Harvest copyWith({
    DateTime? startDate,
    String? coffeeType,
    int? totalQuantity,
    int? quality,
    String? weather,
    String? talhaoId,
    List<String>? usedProducts,
  }) {
    return Harvest(
      id: this.id,
      startDate: startDate ?? this.startDate,
      coffeeType: coffeeType ?? this.coffeeType,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      quality: quality ?? this.quality,
      weather: weather ?? this.weather,
      talhaoId: talhaoId ?? this.talhaoId,
      farmId: this.farmId,
      usedProducts: usedProducts ?? this.usedProducts,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
