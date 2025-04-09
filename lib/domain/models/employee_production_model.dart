import '../interfaces/entity.dart';

class EmployeeProduction implements Entity {
  @override
  final String id;
  final int measureQuantity;
  final double valuePerMeasure;
  final DateTime date;
  final double totalReceived;
  final String employeeId;
  final String harvestId;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeProduction({
    required this.id,
    required this.measureQuantity,
    required this.valuePerMeasure,
    required this.date,
    required this.totalReceived,
    required this.employeeId,
    required this.harvestId,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeProduction.fromMap(Map<String, dynamic> map) {
    return EmployeeProduction(
      id: map['id'],
      measureQuantity: map['measure_quantity'],
      valuePerMeasure: map['value_per_measure'].toDouble(),
      date: DateTime.parse(map['date']),
      totalReceived: map['total_received'].toDouble(),
      employeeId: map['employee_id'],
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
      'measure_quantity': measureQuantity,
      'value_per_measure': valuePerMeasure,
      'date': date.toIso8601String(),
      'total_received': totalReceived,
      'employee_id': employeeId,
      'harvest_id': harvestId,
      'farm_id': farmId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EmployeeProduction copyWith({
    int? measureQuantity,
    double? valuePerMeasure,
    DateTime? date,
    double? totalReceived,
  }) {
    return EmployeeProduction(
      id: this.id,
      measureQuantity: measureQuantity ?? this.measureQuantity,
      valuePerMeasure: valuePerMeasure ?? this.valuePerMeasure,
      date: date ?? this.date,
      totalReceived: totalReceived ?? this.totalReceived,
      employeeId: this.employeeId,
      harvestId: this.harvestId,
      farmId: this.farmId,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
