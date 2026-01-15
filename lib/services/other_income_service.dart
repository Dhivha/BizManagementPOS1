import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/other_income.dart';
import '../utils/storage_manager.dart';

class OtherIncomeService {
  final String baseUrl = '${ApiConfig.baseUrl}${ApiConfig.apiVersion}/universal/OtherIncomes';

  Future<List<OtherIncome>> loadOtherIncomesByDepartment(String department) async {
    try {
      final token = await StorageManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/load-by-department'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(department),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => OtherIncome.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load other incomes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading other incomes: $e');
    }
  }

  Future<void> createOtherIncome(CreateOtherIncomeRequest request) async {
    try {
      final token = await StorageManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 200) {
        final errorBody = response.body;
        throw Exception('Failed to create other income: $errorBody');
      }
    } catch (e) {
      throw Exception('Error creating other income: $e');
    }
  }
}
