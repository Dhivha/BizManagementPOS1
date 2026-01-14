import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../config/api_config.dart';

class ExpenseService {
  Future<Map<String, dynamic>> captureExpense({
    required int userId,
    required DateTime expenseDate,
    required double amount,
    required String category,
    required String narration,
    required String notes,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/universal/Expenses/capture-expense'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'expenseDate': expenseDate.toIso8601String(),
          'amount': amount,
          'category': category,
          'narration': narration,
          'notes': notes,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': response.body};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<List<Expense>> loadExpensesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/universal/Expenses/load-expenses-by-category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      throw Exception('Error loading expenses: $e');
    }
  }
}
