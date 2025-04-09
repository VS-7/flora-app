import '../interfaces/entity.dart';

class ProductUse implements Entity {
  @override
  final String id;
  final DateTime useDate;
  final String description;
  final int usedQuantity;
  final String productId;
  final String? harvestId;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductUse({
    required this.id,
    required this.useDate,
    required this.description,
    required this.usedQuantity,
    required this.productId,
    this.harvestId,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductUse.fromMap(Map<String, dynamic> map) {
    return ProductUse(
      id: map['id'],
      useDate: DateTime.parse(map['use_date']),
      description: map['description'],
      usedQuantity: map['used_quantity'],
      productId: map['product_id'],
      harvestId: map['harvest_id'],
      farmId: map['farm_id'],
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
      'use_date': useDate.toIso8601String(),
      'description': description,
      'used_quantity': usedQuantity,
      'product_id': productId,
      'harvest_id': harvestId,
      'farm_id': farmId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductUse copyWith({
    DateTime? useDate,
    String? description,
    int? usedQuantity,
    String? harvestId,
  }) {
    return ProductUse(
      id: this.id,
      useDate: useDate ?? this.useDate,
      description: description ?? this.description,
      usedQuantity: usedQuantity ?? this.usedQuantity,
      productId: this.productId,
      harvestId: harvestId ?? this.harvestId,
      farmId: this.farmId,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
