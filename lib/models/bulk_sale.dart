class BulkSale {
  final int? id;
  final DateTime dateOfSale;
  final String category;
  final double amount;
  final String capturedBy;
  final DateTime? createdAt;

  BulkSale({
    this.id,
    required this.dateOfSale,
    required this.category,
    required this.amount,
    required this.capturedBy,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateOfSale': dateOfSale.toIso8601String(),
      'category': category,
      'amount': amount,
      'capturedBy': capturedBy,
    };
  }

  factory BulkSale.fromJson(Map<String, dynamic> json) {
    return BulkSale(
      id: json['id'],
      dateOfSale: DateTime.parse(json['dateOfSale']),
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      capturedBy: json['capturedBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
