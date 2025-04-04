import '../interfaces/entity.dart';

enum ActivityType {
  harvest, // Colheita
  pruning, // Poda
  fertilize, // Adubação
  spray, // Pulverização
  watering, // Irrigação
  weeding, // Capina
  planting, // Plantio
  other, // Outros
}

// Extensão para obter uma string amigável para o tipo de atividade
extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.harvest:
        return 'Colheita';
      case ActivityType.pruning:
        return 'Poda';
      case ActivityType.fertilize:
        return 'Adubação';
      case ActivityType.spray:
        return 'Pulverização';
      case ActivityType.watering:
        return 'Irrigação';
      case ActivityType.weeding:
        return 'Capina';
      case ActivityType.planting:
        return 'Plantio';
      case ActivityType.other:
        return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.harvest:
        return '\u1F331'; // 🌱 - Broto
      case ActivityType.pruning:
        return '\u1F52A'; // 🔪 - Faca
      case ActivityType.fertilize:
        return '\u1F4A7'; // 💧 - Gotas
      case ActivityType.spray:
        return '\u1F32C'; // 🌬️ - Vento
      case ActivityType.watering:
        return '\u1F4A6'; // 💦 - Gotículas
      case ActivityType.weeding:
        return '\u1F33F'; // 🌿 - Erva
      case ActivityType.planting:
        return '\u1F33E'; // 🌾 - Arroz
      case ActivityType.other:
        return '\u1F527'; // 🔧 - Chave
    }
  }
}

class Activity implements Entity {
  @override
  final String id;
  final DateTime date;
  final ActivityType type;
  final String description;
  final double? cost;
  final double? areaInHectares;
  final int? quantityInBags;
  final String? notes;

  Activity({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    this.cost,
    this.areaInHectares,
    this.quantityInBags,
    this.notes,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      date: DateTime.parse(map['date']),
      type: ActivityType.values.byName(map['type']),
      description: map['description'],
      cost: map['cost'],
      areaInHectares: map['area_in_hectares'],
      quantityInBags: map['quantity_in_bags'],
      notes: map['notes'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'description': description,
      'cost': cost,
      'area_in_hectares': areaInHectares,
      'quantity_in_bags': quantityInBags,
      'notes': notes,
    };
  }

  Activity copyWith({
    DateTime? date,
    ActivityType? type,
    String? description,
    double? cost,
    double? areaInHectares,
    int? quantityInBags,
    String? notes,
  }) {
    return Activity(
      id: this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      areaInHectares: areaInHectares ?? this.areaInHectares,
      quantityInBags: quantityInBags ?? this.quantityInBags,
      notes: notes ?? this.notes,
    );
  }
}
