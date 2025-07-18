class Item {
  final String id;
  final String invoiceId;
  final String name;
  final String categoryId;
  final double quantity;
  final double unitPrice;
  final double total;
  final String? description;

  Item({
    required this.id,
    required this.invoiceId,
    required this.name,
    required this.categoryId,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.description,
  });

  // Factory constructor para criar Item a partir de Map
  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      invoiceId: map['invoiceId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      quantity: (map['quantity'] as num? ?? 0).toDouble(),
      unitPrice: (map['unitPrice'] as num? ?? 0).toDouble(),
      total: (map['total'] as num? ?? 0).toDouble(),
      description: map['description'] as String?,
    );
  }

  // Método para converter Item para Map
  Map<String, dynamic> toMap() {
    return {
      'invoiceId': invoiceId,
      'name': name,
      'categoryId': categoryId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
      'description': description,
    };
  }

  // Método copyWith para criar cópias com alterações
  Item copyWith({
    String? id,
    String? invoiceId,
    String? name,
    String? categoryId,
    double? quantity,
    double? unitPrice,
    double? total,
    String? description,
  }) {
    return Item(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      description: description ?? this.description,
    );
  }
}