import '../interfaces/entity.dart';

class Employee implements Entity {
  @override
  final String id;
  final String name;
  final String role;
  final double cost;
  final String? photoUrl;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.cost,
    this.photoUrl,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      cost: map['cost'].toDouble(),
      photoUrl: map['photo_url'],
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
      'role': role,
      'cost': cost,
      'photo_url': photoUrl,
      'farm_id': farmId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Employee copyWith({
    String? name,
    String? role,
    double? cost,
    String? photoUrl,
  }) {
    return Employee(
      id: this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      cost: cost ?? this.cost,
      photoUrl: photoUrl ?? this.photoUrl,
      farmId: this.farmId,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
