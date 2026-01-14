class Expense {
  final int id;
  final int userId;
  final String userFirstName;
  final String userLastName;
  final DateTime expenseDate;
  final DateTime createdAt;
  final double amount;
  final String category;
  final String narration;
  final String notes;
  final String paymentMethod;

  Expense({
    required this.id,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    required this.expenseDate,
    required this.createdAt,
    required this.amount,
    required this.category,
    required this.narration,
    required this.notes,
    required this.paymentMethod,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['userId'],
      userFirstName: json['userFirstName'],
      userLastName: json['userLastName'],
      expenseDate: DateTime.parse(json['expenseDate']),
      createdAt: DateTime.parse(json['createdAt']),
      amount: json['amount'].toDouble(),
      category: json['category'],
      narration: json['narration'],
      notes: json['notes'],
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'expenseDate': expenseDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'amount': amount,
      'category': category,
      'narration': narration,
      'notes': notes,
      'paymentMethod': paymentMethod,
    };
  }
}
