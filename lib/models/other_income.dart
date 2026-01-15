class OtherIncome {
  final int id;
  final DateTime dateTimeCaptured;
  final double amount;
  final String narration;
  final String category;
  final String department;
  final DateTime createdAt;

  OtherIncome({
    required this.id,
    required this.dateTimeCaptured,
    required this.amount,
    required this.narration,
    required this.category,
    required this.department,
    required this.createdAt,
  });

  factory OtherIncome.fromJson(Map<String, dynamic> json) {
    return OtherIncome(
      id: json['id'],
      dateTimeCaptured: DateTime.parse(json['dateTimeCaptured']),
      amount: (json['amount'] as num).toDouble(),
      narration: json['narration'],
      category: json['category'],
      department: json['department'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTimeCaptured': dateTimeCaptured.toIso8601String(),
      'amount': amount,
      'narration': narration,
      'category': category,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CreateOtherIncomeRequest {
  final DateTime dateTimeCaptured;
  final double amount;
  final String narration;
  final String category;
  final String department;

  CreateOtherIncomeRequest({
    required this.dateTimeCaptured,
    required this.amount,
    required this.narration,
    required this.category,
    required this.department,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTimeCaptured': dateTimeCaptured.toIso8601String(),
      'amount': amount,
      'narration': narration,
      'category': category,
      'department': department,
    };
  }
}
