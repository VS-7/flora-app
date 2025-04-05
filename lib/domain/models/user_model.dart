import '../interfaces/entity.dart';

class User implements Entity {
  @override
  final String id;
  final String name;
  final String farmName;
  final String? location;

  User({
    required this.id,
    required this.name,
    required this.farmName,
    this.location,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      farmName: map['farm_name'],
      location: map['location'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'farm_name': farmName,
      'location': location,
    };
  }

  User copyWith({String? name, String? farmName, String? location}) {
    return User(
      id: this.id,
      name: name ?? this.name,
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
    );
  }
}
