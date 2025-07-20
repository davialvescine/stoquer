class Asset {
  final String id;
  final String name;
  final String description;
  final String category;
  final String qrCode;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageUrl;
  final double value;
  final String status;

  Asset({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.qrCode,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
    required this.value,
    required this.status,
  });

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      qrCode: map['qrCode'] ?? '',
      location: map['location'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      imageUrl: map['imageUrl'] ?? '',
      value: (map['value'] ?? 0).toDouble(),
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'qrCode': qrCode,
      'location': location,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'value': value,
      'status': status,
    };
  }

  Asset copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? qrCode,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    double? value,
    String? status,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      qrCode: qrCode ?? this.qrCode,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      value: value ?? this.value,
      status: status ?? this.status,
    );
  }
}