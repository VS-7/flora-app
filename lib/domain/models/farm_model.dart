import '../interfaces/entity.dart';

class Farm implements Entity {
  @override
  final String id;
  final String name;
  final String? location;
  final String userId;
  final String? description;
  final double? totalArea;
  final String? mainCrop;
  final DateTime createdAt;
  final DateTime updatedAt;

  Farm({
    required this.id,
    required this.name,
    this.location,
    required this.userId,
    this.description,
    this.totalArea,
    this.mainCrop,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      userId: map['user_id'],
      description: map['description'],
      totalArea:
          map['total_area'] != null ? map['total_area'].toDouble() : null,
      mainCrop: map['main_crop'],
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
      'location': location,
      'user_id': userId,
      'description': description,
      'total_area': totalArea,
      'main_crop': mainCrop,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Farm copyWith({
    String? name,
    String? location,
    String? description,
    double? totalArea,
    String? mainCrop,
  }) {
    return Farm(
      id: this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      userId: this.userId,
      description: description ?? this.description,
      totalArea: totalArea ?? this.totalArea,
      mainCrop: mainCrop ?? this.mainCrop,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
