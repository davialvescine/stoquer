class Location {
  final String id;
  String name;

  Location({required this.id, required this.name});

  factory Location.fromMap(String id, Map<String, dynamic> data) {
    return Location(id: id, name: data['name'] as String? ?? '');
  }

  Map<String, dynamic> toMap() => {'name': name};
}
