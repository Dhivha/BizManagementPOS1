import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  List<Expense> get filteredExpenses => _filteredExpenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>> captureExpense({
    required int userId,
    required DateTime expenseDate,
    required double amount,
    required String category,
    required String narration,
    required String notes,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _expenseService.captureExpense(
        userId: userId,
        expenseDate: expenseDate,
        amount: amount,
        category: category,
        narration: narration,
        notes: notes,
        paymentMethod: paymentMethod,
      );

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<void> loadExpensesByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _expenseService.loadExpensesByCategory(category);
      _filteredExpenses = _expenses;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void filterByDateRange(DateTime startDate, DateTime endDate) {
    _filteredExpenses = _expenses.where((expense) {
      return expense.expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expense.expenseDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    notifyListeners();
  }

  void clearFilter() {
    _filteredExpenses = _expenses;
    notifyListeners();
  }
}
