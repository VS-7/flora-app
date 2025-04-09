import '../interfaces/entity.dart';

class Task implements Entity {
  @override
  final String id;
  final String description;
  final DateTime date;
  final String type; // "daily" or "other"
  final double dailyRate;
  final String farmId;
  final List<String>? assignedEmployees; // List of employee IDs
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.description,
    required this.date,
    required this.type,
    required this.dailyRate,
    required this.farmId,
    this.assignedEmployees,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      dailyRate: map['daily_rate'].toDouble(),
      farmId: map['farm_id'],
      assignedEmployees:
          map['assigned_employees'] != null
              ? List<String>.from(map['assigned_employees'])
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
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
      'daily_rate': dailyRate,
      'farm_id': farmId,
      'assigned_employees': assignedEmployees,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? description,
    DateTime? date,
    String? type,
    double? dailyRate,
    List<String>? assignedEmployees,
  }) {
    return Task(
      id: this.id,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      dailyRate: dailyRate ?? this.dailyRate,
      farmId: this.farmId,
      assignedEmployees: assignedEmployees ?? this.assignedEmployees,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
