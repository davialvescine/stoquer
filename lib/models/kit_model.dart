class Kit {
  final String id;
  String name;
  List<String> assetIds;

  Kit({required this.id, required this.name, required this.assetIds});

  factory Kit.fromMap(String id, Map<String, dynamic> data) {
    return Kit(
      id: id,
      name: data['name'] as String? ?? '',
      assetIds: List<String>.from(data['assetIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'assetIds': assetIds};
}
