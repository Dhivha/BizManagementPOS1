class Product {
  final int id;
  final String productId;
  final String productName;
  final String category;
  final String description;
  final double pricePerUnit;
  final int currentInStockInUnit;
  final String? unit;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Product({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.description,
    required this.pricePerUnit,
    required this.currentInStockInUnit,
    this.unit,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      currentInStockInUnit: (json['currentInStockInUnit'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'category': category,
      'description': description,
      'pricePerUnit': pricePerUnit,
      'currentInStockInUnit': currentInStockInUnit,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'category': category,
      'description': description,
      'pricePerUnit': pricePerUnit,
      'currentInStockInUnit': currentInStockInUnit,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      pricePerUnit: map['pricePerUnit'] as double,
      currentInStockInUnit: map['currentInStockInUnit'] as int,
      unit: map['unit'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      isActive: (map['isActive'] as int) == 1,
    );
  }

  // Helper method to format price
  String get formattedPrice => '\$${pricePerUnit.toStringAsFixed(2)}';

  // Helper method for search
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return productId.toLowerCase().contains(lowerQuery) ||
           productName.toLowerCase().contains(lowerQuery) ||
           category.toLowerCase().contains(lowerQuery) ||
           description.toLowerCase().contains(lowerQuery) ||
           pricePerUnit.toString().contains(lowerQuery);
  }
}