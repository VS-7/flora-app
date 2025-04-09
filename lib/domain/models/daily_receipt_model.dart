import '../interfaces/entity.dart';

class DailyReceipt implements Entity {
  @override
  final String id;
  final DateTime date;
  final String type; // "harvest" or "task"
  final String description;
  final double amountPaid;
  final int? measure; // if type is harvest
  final String printStatus; // "printed", "pending"
  final String employeeId;
  final String? harvestId;
  final String? taskId;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyReceipt({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    required this.amountPaid,
    this.measure,
    required this.printStatus,
    required this.employeeId,
    this.harvestId,
    this.taskId,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyReceipt.fromMap(Map<String, dynamic> map) {
    return DailyReceipt(
      id: map['id'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      description: map['description'],
      amountPaid: map['amount_paid'].toDouble(),
      measure: map['measure'],
      printStatus: map['print_status'],
      employeeId: map['employee_id'],
      harvestId: map['harvest_id'],
      taskId: map['task_id'],
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
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'amount_paid': amountPaid,
      'measure': measure,
      'print_status': printStatus,
      'employee_id': employeeId,
      'harvest_id': harvestId,
      'task_id': taskId,
      'farm_id': farmId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DailyReceipt copyWith({
    DateTime? date,
    String? type,
    String? description,
    double? amountPaid,
    int? measure,
    String? printStatus,
  }) {
    return DailyReceipt(
      id: this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      amountPaid: amountPaid ?? this.amountPaid,
      measure: measure ?? this.measure,
      printStatus: printStatus ?? this.printStatus,
      employeeId: this.employeeId,
      harvestId: this.harvestId,
      taskId: this.taskId,
      farmId: this.farmId,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
