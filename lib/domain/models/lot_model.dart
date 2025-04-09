import '../interfaces/entity.dart';

class Lot implements Entity {
  @override
  final String id;
  final String name;
  final double area;
  final String currentHarvest;
  final Map<String, double>? coordinates;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lot({
    required this.id,
    required this.name,
    required this.area,
    required this.currentHarvest,
    this.coordinates,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lot.fromMap(Map<String, dynamic> map) {
    return Lot(
      id: map['id'],
      name: map['name'],
      area: map['area'].toDouble(),
      currentHarvest: map['current_harvest'],
      coordinates:
          map['coordinates'] != null
              ? Map<String, double>.from(map['coordinates'])
              : null,
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
      'name': name,
      'area': area,
      'current_harvest': currentHarvest,
      'coordinates': coordinates,
      'farm_id': farmId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Lot copyWith({
    String? name,
    double? area,
    String? currentHarvest,
    Map<String, double>? coordinates,
  }) {
    return Lot(
      id: this.id,
      name: name ?? this.name,
      area: area ?? this.area,
      currentHarvest: currentHarvest ?? this.currentHarvest,
      coordinates: coordinates ?? this.coordinates,
      farmId: this.farmId,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
