import 'dart:convert';
import '../interfaces/entity.dart';

class Harvest implements Entity {
  @override
  final String id;
  final String name; // E.g., "Colheita 2025"
  final int year;
  final DateTime startDate;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Harvest({
    required this.id,
    required this.name,
    required this.year,
    required this.startDate,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Harvest.fromMap(Map<String, dynamic> map) {
    return Harvest(
      id: map['id'],
      name: map['name'],
      year: map['year'],
      startDate: DateTime.parse(map['start_date']),
      farmId: map['farm_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'start_date': startDate.toIso8601String(),
      'farm_id': farmId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory Harvest.fromJson(String source) =>
      Harvest.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Harvest(id: $id, name: $name, year: $year, startDate: $startDate, farmId: $farmId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  Harvest copyWith({
    String? id,
    String? name,
    int? year,
    DateTime? startDate,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Harvest(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      startDate: startDate ?? this.startDate,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
