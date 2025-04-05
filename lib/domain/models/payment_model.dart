import '../interfaces/entity.dart';

class Payment implements Entity {
  @override
  final String id;
  final DateTime date;
  final double amount;
  final String collaboratorId;
  final String? description;

  Payment({
    required this.id,
    required this.date,
    required this.amount,
    required this.collaboratorId,
    this.description,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      collaboratorId: map['collaborator_id'],
      description: map['description'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'collaborator_id': collaboratorId,
      'description': description,
    };
  }

  Payment copyWith({
    DateTime? date,
    double? amount,
    String? collaboratorId,
    String? description,
  }) {
    return Payment(
      id: this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      collaboratorId: collaboratorId ?? this.collaboratorId,
      description: description ?? this.description,
    );
  }
}
