import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/purchase.dart';
import '../utils/storage_manager.dart';

class PurchasesService {
  final String baseUrl = '${ApiConfig.baseUrl}${ApiConfig.apiVersion}/butchery/Purchases';

  Future<List<Purchase>> loadPurchases() async {
    try {
      final token = await StorageManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/load-purchases'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Purchase.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load purchases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading purchases: $e');
    }
  }

  Future<void> addPurchase(CreatePurchaseRequest request) async {
    try {
      final token = await StorageManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add-purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 200) {
        final errorBody = response.body;
        throw Exception('Failed to add purchase: $errorBody');
      }
    } catch (e) {
      throw Exception('Error adding purchase: $e');
    }
  }

  Future<List<Purchase>> loadPurchasesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final token = await StorageManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/load-purchases-by-date-range?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Purchase.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load purchases by date range: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading purchases by date range: $e');
    }
  }

  Future<void> reversePurchase(int purchaseId, String reversalReason) async {
    try {
      final token = await StorageManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reverse-purchase/$purchaseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(reversalReason),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to reverse purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error reversing purchase: $e');
    }
  }
}
