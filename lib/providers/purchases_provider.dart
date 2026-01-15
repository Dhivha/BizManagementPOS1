import 'package:flutter/material.dart';
import '../models/purchase.dart';
import '../services/purchases_service.dart';

class PurchasesProvider with ChangeNotifier {
  final PurchasesService _purchasesService = PurchasesService();

  List<Purchase> _purchases = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Purchase> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalPurchasesInvoiceAmount {
    return _purchases.fold(0, (sum, purchase) => sum + purchase.purchasesInvoiceAmount);
  }

  Future<void> loadPurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _purchases = await _purchasesService.loadPurchases();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPurchase(CreatePurchaseRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _purchasesService.addPurchase(request);
      await loadPurchases(); // Reload purchases after adding
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadPurchasesByDateRange(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _purchases = await _purchasesService.loadPurchasesByDateRange(startDate, endDate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reversePurchase(int purchaseId, String reversalReason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _purchasesService.reversePurchase(purchaseId, reversalReason);
      await loadPurchases(); // Reload purchases after reversing
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
