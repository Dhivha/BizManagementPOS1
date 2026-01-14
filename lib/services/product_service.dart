import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ApiService _apiService = ApiService();

  // Load products from API
  Future<List<Product>> loadProducts() async {
    try {
      debugPrint('🛒 Loading products from API...');

      final response = await _apiService.get(ApiEndpoints.loadProducts);

      debugPrint('✅ Products loaded successfully');

      if (response is List) {
        final products = response
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('📦 Parsed ${products.length} products');
        return products;
      } else {
        throw Exception(
            'Invalid response format: expected List, got ${response.runtimeType}');
      }
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  // Create a new product
  Future<bool> createProduct({
    required String productName,
    required String category,
    required String description,
    required double pricePerUnit,
    required int currentInStockInUnit,
  }) async {
    try {
      debugPrint('🛒 Creating new product: $productName');

      await _apiService.post(
        ApiEndpoints.createProduct,
        body: {
          'productName': productName,
          'category': category,
          'description': description,
          'pricePerUnit': pricePerUnit,
          'currentInStockInUnit': currentInStockInUnit,
        },
      );

      debugPrint('✅ Product created successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating product: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  // Update product
  Future<bool> updateProduct({
    required int id,
    String? productName,
    String? category,
    String? description,
    double? pricePerUnit,
  }) async {
    try {
      debugPrint('🛒 Updating product ID: $id');

      final body = <String, dynamic>{};
      if (productName != null) body['productName'] = productName;
      if (category != null) body['category'] = category;
      if (description != null) body['description'] = description;
      if (pricePerUnit != null) body['pricePerUnit'] = pricePerUnit;

      await _apiService.put(
        ApiEndpoints.updateProduct(id),
        body: body,
      );

      debugPrint('✅ Product updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  // Update product by product ID
  Future<bool> updateProductByProductId({
    required String productId,
    String? productName,
    String? category,
    String? description,
    double? pricePerUnit,
  }) async {
    try {
      debugPrint('🛒 Updating product by ProductID: $productId');

      final body = <String, dynamic>{};
      if (productName != null) body['productName'] = productName;
      if (category != null) body['category'] = category;
      if (description != null) body['description'] = description;
      if (pricePerUnit != null) body['pricePerUnit'] = pricePerUnit;

      await _apiService.put(
        ApiEndpoints.updateProductByProductId(productId),
        body: body,
      );

      debugPrint('✅ Product updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  // Get price per unit
  Future<double?> getPricePerUnit(String productId) async {
    try {
      debugPrint('🛒 Getting price for product: $productId');

      final response =
          await _apiService.get(ApiEndpoints.getPricePerUnit(productId));

      debugPrint('✅ Price retrieved successfully');
      return response['pricePerUnit']?.toDouble();
    } catch (e) {
      debugPrint('❌ Error getting price: $e');
      throw Exception('Failed to get price: $e');
    }
  }

  // Update price per unit
  Future<bool> updatePricePerUnit(String productId, double newPrice) async {
    try {
      debugPrint(
          '🛒 Updating price for product: $productId to \$${newPrice.toStringAsFixed(2)}');

      await _apiService.put(
        ApiEndpoints.updatePricePerUnit(productId),
        body: {'pricePerUnit': newPrice},
      );

      debugPrint('✅ Price updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating price: $e');
      throw Exception('Failed to update price: $e');
    }
  }

  // Delete product
  Future<bool> deleteProduct(int id) async {
    try {
      debugPrint('🛒 Deleting product ID: $id');

      await _apiService.delete(ApiEndpoints.deleteProduct(id));

      debugPrint('✅ Product deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }
}
