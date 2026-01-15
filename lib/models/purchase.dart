class Purchase {
  final int id;
  final DateTime dateOfPurchases;
  final double purchasesInvoiceAmount;
  final String currency;
  final double amountPaid;
  final double amountOwing;
  final double purchasesExpenses;
  final String department;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PurchaseItem> items;

  Purchase({
    required this.id,
    required this.dateOfPurchases,
    required this.purchasesInvoiceAmount,
    required this.currency,
    required this.amountPaid,
    required this.amountOwing,
    required this.purchasesExpenses,
    required this.department,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      dateOfPurchases: DateTime.parse(json['dateOfPurchases']),
      purchasesInvoiceAmount: (json['purchasesInvoiceAmount'] as num).toDouble(),
      currency: json['currency'],
      amountPaid: (json['amountPaid'] as num).toDouble(),
      amountOwing: (json['amountOwing'] as num).toDouble(),
      purchasesExpenses: (json['purchasesExpenses'] as num).toDouble(),
      department: json['department'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      items: (json['items'] as List?)
              ?.map((item) => PurchaseItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateOfPurchases': dateOfPurchases.toIso8601String(),
      'purchasesInvoiceAmount': purchasesInvoiceAmount,
      'currency': currency,
      'amountPaid': amountPaid,
      'amountOwing': amountOwing,
      'purchasesExpenses': purchasesExpenses,
      'department': department,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class PurchaseItem {
  final int id;
  final String productId;
  final String productName;
  final double quantityInUnits;
  final double unitCost;
  final double totalAmount;

  PurchaseItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantityInUnits,
    required this.unitCost,
    required this.totalAmount,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantityInUnits: (json['quantityInUnits'] as num).toDouble(),
      unitCost: (json['unitCost'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantityInUnits': quantityInUnits,
      'unitCost': unitCost,
      'totalAmount': totalAmount,
    };
  }
}

class CreatePurchaseRequest {
  final DateTime dateOfPurchases;
  final double purchasesInvoiceAmount;
  final String currency;
  final double amountPaid;
  final double purchasesExpenses;
  final String department;
  final String? notes;
  final List<CreatePurchaseItemRequest> items;

  CreatePurchaseRequest({
    required this.dateOfPurchases,
    required this.purchasesInvoiceAmount,
    required this.currency,
    required this.amountPaid,
    required this.purchasesExpenses,
    required this.department,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateOfPurchases': dateOfPurchases.toIso8601String(),
      'purchasesInvoiceAmount': purchasesInvoiceAmount,
      'currency': currency,
      'amountPaid': amountPaid,
      'purchasesExpenses': purchasesExpenses,
      'department': department,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CreatePurchaseItemRequest {
  final String productId;
  final double quantityInUnits;
  final double unitCost;

  CreatePurchaseItemRequest({
    required this.productId,
    required this.quantityInUnits,
    required this.unitCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantityInUnits': quantityInUnits,
      'unitCost': unitCost,
    };
  }
}
