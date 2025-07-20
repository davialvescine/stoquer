class Emprestimo {
  final String id;
  final String assetId;
  final String assetName;
  final String borrowerName;
  final String borrowerEmail;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? returnDate;
  final String status;
  final String notes;

  Emprestimo({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.borrowerName,
    required this.borrowerEmail,
    required this.startDate,
    this.endDate,
    this.returnDate,
    required this.status,
    this.notes = '',
  });

  factory Emprestimo.fromMap(Map<String, dynamic> map) {
    return Emprestimo(
      id: map['id'] ?? '',
      assetId: map['assetId'] ?? '',
      assetName: map['assetName'] ?? '',
      borrowerName: map['borrowerName'] ?? '',
      borrowerEmail: map['borrowerEmail'] ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: map['endDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate']) 
          : null,
      returnDate: map['returnDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['returnDate']) 
          : null,
      status: map['status'] ?? 'active',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetId': assetId,
      'assetName': assetName,
      'borrowerName': borrowerName,
      'borrowerEmail': borrowerEmail,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'returnDate': returnDate?.millisecondsSinceEpoch,
      'status': status,
      'notes': notes,
    };
  }

  Emprestimo copyWith({
    String? id,
    String? assetId,
    String? assetName,
    String? borrowerName,
    String? borrowerEmail,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? returnDate,
    String? status,
    String? notes,
  }) {
    return Emprestimo(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}