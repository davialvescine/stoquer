class Category {
  final String id;
  String name;

  Category({required this.id, required this.name});

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(id: id, name: data['name'] as String? ?? '');
  }

  Map<String, dynamic> toMap() => {'name': name};
}