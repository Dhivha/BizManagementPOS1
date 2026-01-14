import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import 'api_service.dart';

class SalesService {
  final ApiService _apiService = ApiService();

  Future<bool> addSale(Sale sale) async {
    try {
      debugPrint('SalesService: Attempting to add sale ${sale.id}');
      
      await _apiService.post(
        '/butchery/Sales/add-sale',
        body: sale.toApiPayload(),
      );
      
      // ApiService returns Map<String, dynamic> on success
      debugPrint('SalesService: Sale ${sale.id} successfully synced to API');
      return true;
    } catch (e) {
      debugPrint('SalesService: Error syncing sale ${sale.id}: $e');
      return false;
    }
  }
}