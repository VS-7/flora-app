import '../interfaces/entity.dart';

class Product implements Entity {
  @override
  final String id;
  final String name;
  final String type;
  final String? expirationDate;
  final int quantity;
  final String status;
  final String? photoUrl;
  final String? barcode;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.type,
    this.expirationDate,
    required this.quantity,
    required this.status,
    this.photoUrl,
    this.barcode,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      expirationDate: map['expiration_date'],
      quantity: map['quantity'],
      status: map['status'],
      photoUrl: map['photo_url'],
      barcode: map['barcode'],
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
      'type': type,
      'expiration_date': expirationDate,
      'quantity': quantity,
      'status': status,
      'photo_url': photoUrl,
      'barcode': barcode,
      'farm_id': farmId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? name,
    String? type,
    String? expirationDate,
    int? quantity,
    String? status,
    String? photoUrl,
    String? barcode,
  }) {
    return Product(
      id: this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      expirationDate: expirationDate ?? this.expirationDate,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      barcode: barcode ?? this.barcode,
      farmId: this.farmId,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
