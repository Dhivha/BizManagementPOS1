import 'package:flutter/material.dart';
import '../models/other_income.dart';
import '../services/other_income_service.dart';

class OtherIncomeProvider with ChangeNotifier {
  final OtherIncomeService _otherIncomeService = OtherIncomeService();

  List<OtherIncome> _otherIncomes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OtherIncome> get otherIncomes => _otherIncomes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAmount {
    return _otherIncomes.fold(0, (sum, income) => sum + income.amount);
  }

  Future<void> loadOtherIncomes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _otherIncomes = await _otherIncomeService.loadOtherIncomesByDepartment('Butchery');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOtherIncome(CreateOtherIncomeRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _otherIncomeService.createOtherIncome(request);
      await loadOtherIncomes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
