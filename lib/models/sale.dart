class Sale {
  final String id;
  final DateTime dateOfSale;
  final String currency;
  final String department;
  final String? notes;
  final double totalAmount;
  final DateTime createdAt;
  final bool isQueued; // true for QueuedSales, false for SyncedSales
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.dateOfSale,
    required this.currency,
    required this.department,
    this.notes,
    required this.totalAmount,
    required this.createdAt,
    this.isQueued = true,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateOfSale': dateOfSale.toIso8601String(),
      'currency': currency,
      'department': department,
      'notes': notes,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      dateOfSale: DateTime.parse(map['dateOfSale']),
      currency: map['currency'],
      department: map['department'],
      notes: map['notes'],
      totalAmount: map['totalAmount'].toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      isQueued: true,
      items: [], // Will be loaded separately
    );
  }

  factory Sale.fromMapSynced(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      dateOfSale: DateTime.parse(map['dateOfSale']),
      currency: map['currency'],
      department: map['department'],
      notes: map['notes'],
      totalAmount: map['totalAmount'].toDouble(),
      createdAt: DateTime.parse(map['syncedAt']), // Use syncedAt for synced sales
      isQueued: false,
      items: [], // Will be loaded separately
    );
  }

  // For API payload
  Map<String, dynamic> toApiPayload() {
    return {
      'dateOfSale': dateOfSale.toIso8601String(),
      'currency': currency,
      'department': department,
      'notes': notes ?? '',
      'items': items.map((item) => item.toApiPayload()).toList(),
    };
  }

  Sale copyWith({
    String? id,
    DateTime? dateOfSale,
    String? currency,
    String? department,
    String? notes,
    double? totalAmount,
    DateTime? createdAt,
    bool? isQueued,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      dateOfSale: dateOfSale ?? this.dateOfSale,
      currency: currency ?? this.currency,
      department: department ?? this.department,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      isQueued: isQueued ?? this.isQueued,
      items: items ?? this.items,
    );
  }
}

class SaleItem {
  final int? id;
  final String? saleId;
  final String productId;
  final String productName;
  final double quantityInUnits; // Decimal quantity
  final double pricePerUnit;
  final double totalPrice;

  SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    required this.productName,
    required this.quantityInUnits,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'productName': productName,
      'quantityInUnits': quantityInUnits,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      productName: map['productName'],
      quantityInUnits: map['quantityInUnits'].toDouble(),
      pricePerUnit: map['pricePerUnit'].toDouble(),
      totalPrice: map['totalPrice'].toDouble(),
    );
  }

  // For API payload - only productId and quantityInUnits
  Map<String, dynamic> toApiPayload() {
    return {
      'productId': productId,
      'quantityInUnits': quantityInUnits,
    };
  }
}