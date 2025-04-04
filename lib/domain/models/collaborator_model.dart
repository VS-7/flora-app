import '../interfaces/entity.dart';

class Collaborator implements Entity {
  @override
  final String id;
  final String name;
  final double dailyRate;

  Collaborator({required this.id, required this.name, required this.dailyRate});

  factory Collaborator.fromMap(Map<String, dynamic> map) {
    return Collaborator(
      id: map['id'],
      name: map['name'],
      dailyRate: map['daily_rate'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'daily_rate': dailyRate};
  }

  Collaborator copyWith({String? name, double? dailyRate}) {
    return Collaborator(
      id: this.id,
      name: name ?? this.name,
      dailyRate: dailyRate ?? this.dailyRate,
    );
  }
}
