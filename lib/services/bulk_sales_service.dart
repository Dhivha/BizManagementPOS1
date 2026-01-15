import 'package:flutter/foundation.dart';
import '../models/bulk_sale.dart';
import 'api_service.dart';

class BulkSalesService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> addBulkSale(BulkSale bulkSale) async {
    try {
      debugPrint('BulkSalesService: Attempting to add bulk sale');
      
      final response = await _apiService.post(
        '/butchery/BulkSales/add-bulk-sale',
        body: bulkSale.toJson(),
      );
      
      debugPrint('BulkSalesService: Bulk sale successfully added');
      return {'success': true, 'message': 'Bulk sale added successfully', 'data': response};
    } catch (e) {
      debugPrint('BulkSalesService: Error adding bulk sale: $e');
      return {'success': false, 'message': 'Failed to add bulk sale: $e'};
    }
  }

  Future<List<BulkSale>> getAllBulkSales() async {
    try {
      debugPrint('BulkSalesService: Fetching all bulk sales');
      
      final response = await _apiService.get('/butchery/BulkSales/get-all-bulk-sales');
      
      if (response is List) {
        final bulkSales = response.map((json) => BulkSale.fromJson(json)).toList();
        debugPrint('BulkSalesService: Fetched ${bulkSales.length} bulk sales');
        return bulkSales;
      }
      
      return [];
    } catch (e) {
      debugPrint('BulkSalesService: Error fetching bulk sales: $e');
      return [];
    }
  }

  Future<double> getTotalBulkSales() async {
    try {
      final bulkSales = await getAllBulkSales();
      double total = 0.0;
      for (var sale in bulkSales) {
        total += sale.amount;
      }
      return total;
    } catch (e) {
      debugPrint('BulkSalesService: Error calculating total bulk sales: $e');
      return 0.0;
    }
  }

  Future<double> getTotalSalesAmount() async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      final endDate = now.add(const Duration(days: 1));
      
      debugPrint('BulkSalesService: Fetching total sales from $startDate to $endDate');
      
      final response = await _apiService.get(
        '/butchery/BulkSales/get-total-sales-amount?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}',
      );
      
      final total = (response as num).toDouble();
      debugPrint('BulkSalesService: Total sales amount: \$$total');
      return total;
    } catch (e) {
      debugPrint('BulkSalesService: Error fetching total sales amount: $e');
      return 0.0;
    }
  }
}
