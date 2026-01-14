import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/database_helper.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasProducts => _products.isNotEmpty;

  final ProductService _productService = ProductService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Initialize products from local database
  Future<void> initializeProducts() async {
    _setLoading(true);

    try {
      // Load products from local database first
      final localProducts = await _databaseHelper.getAllProducts();
      _products = localProducts;
      _filteredProducts = localProducts;
      notifyListeners();

      // Then sync with API in background
      await syncWithApi();
    } catch (e) {
      _setError('Failed to initialize products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load products from API and sync with local database - ONLY ADD NEW PRODUCTS
  Future<void> syncWithApi() async {
    try {
      debugPrint('🔄 Syncing products with API...');

      final apiProducts = await _productService.loadProducts();
      
      // Get existing local products to compare
      final localProducts = await _databaseHelper.getAllProducts();
      final localProductIds = localProducts.map((p) => p.productId).toSet();
      
      // Find only NEW products from API that are not in local DB
      final newProducts = apiProducts.where((apiProduct) => 
          !localProductIds.contains(apiProduct.productId)).toList();
      
      if (newProducts.isNotEmpty) {
        // Insert only new products
        await _databaseHelper.insertProducts(newProducts);
        
        // Reload all products from local DB to update state
        final updatedLocalProducts = await _databaseHelper.getAllProducts();
        _products = updatedLocalProducts;
        _applySearch();
        
        debugPrint('✅ Added ${newProducts.length} new products. Total: ${updatedLocalProducts.length} items');
      } else {
        debugPrint('✅ No new products found. Local count: ${localProducts.length} items');
      }

      _setError(null);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
      _setError('Failed to sync products: ${e.toString()}');
      notifyListeners();
    }
  }

  // Manually refresh products from API
  Future<void> refreshProducts() async {
    _setLoading(true);

    try {
      await syncWithApi();
    } finally {
      _setLoading(false);
    }
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  // Apply search filter
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((product) => product.matchesSearch(_searchQuery))
          .toList();
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  // Get product by ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get product by product ID
  Product? getProductByProductId(String productId) {
    try {
      return _products.firstWhere((product) => product.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Add product locally (for future implementation)
  Future<void> addProduct(Product product) async {
    try {
      await _databaseHelper.insertProduct(product);
      _products.add(product);
      _applySearch();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add product: ${e.toString()}');
    }
  }

  // Update product locally (for future implementation)
  Future<void> updateProduct(Product product) async {
    try {
      await _databaseHelper.updateProduct(product);

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applySearch();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update product: ${e.toString()}');
    }
  }

  // Delete product locally (for future implementation)
  Future<void> deleteProduct(int id) async {
    try {
      await _databaseHelper.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      _applySearch();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete product: ${e.toString()}');
    }
  }

  // Get categories list
  List<String> get categories {
    final categorySet = <String>{};
    for (final product in _products) {
      categorySet.add(product.category);
    }
    return categorySet.toList()..sort();
  }

  // Filter by category
  void filterByCategory(String category) {
    if (category.isEmpty || category == 'All') {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts =
          _products.where((product) => product.category == category).toList();
    }
    notifyListeners();
  }

  // Get product statistics
  Map<String, dynamic> get statistics {
    return {
      'totalProducts': _products.length,
      'categories': categories.length,
      'averagePrice': _products.isNotEmpty
          ? _products.map((p) => p.pricePerUnit).reduce((a, b) => a + b) /
              _products.length
          : 0.0,
      'highestPrice': _products.isNotEmpty
          ? _products.map((p) => p.pricePerUnit).reduce((a, b) => a > b ? a : b)
          : 0.0,
      'lowestPrice': _products.isNotEmpty
          ? _products.map((p) => p.pricePerUnit).reduce((a, b) => a < b ? a : b)
          : 0.0,
    };
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _databaseHelper.clearAllProducts();
    _products.clear();
    _filteredProducts.clear();
    _searchQuery = '';
    _error = null;
    notifyListeners();
  }
}
