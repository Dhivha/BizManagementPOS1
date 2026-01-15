import 'package:flutter/material.dart';
import '../models/bulk_sale.dart';
import '../services/bulk_sales_service.dart';

class BulkSalesProvider with ChangeNotifier {
  final BulkSalesService _bulkSalesService = BulkSalesService();
  
  List<BulkSale> _bulkSales = [];
  bool _isLoading = false;
  String? _error;

  List<BulkSale> get bulkSales => _bulkSales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>> addBulkSale({
    required DateTime dateOfSale,
    required String category,
    required double amount,
    required String capturedBy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bulkSale = BulkSale(
        dateOfSale: dateOfSale,
        category: category,
        amount: amount,
        capturedBy: capturedBy,
      );

      final result = await _bulkSalesService.addBulkSale(bulkSale);
      
      if (result['success']) {
        await loadBulkSales();
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<void> loadBulkSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bulkSales = await _bulkSalesService.getAllBulkSales();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<double> getTotalSalesAmount() async {
    try {
      return await _bulkSalesService.getTotalSalesAmount();
    } catch (e) {
      return 0.0;
    }
  }
}
