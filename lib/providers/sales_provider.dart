import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/sales_service.dart';
import '../services/bluetooth_receipt_service.dart';
import '../utils/database_helper.dart';

class SalesProvider extends ChangeNotifier {
  final SalesService _salesService = SalesService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final BluetoothReceiptService _receiptService = BluetoothReceiptService();

  List<Sale> _queuedSales = [];
  List<Sale> _syncedSales = [];
  bool _isLoading = false;
  User? _currentUser;

  List<Sale> get queuedSales => _queuedSales;
  List<Sale> get syncedSales => _syncedSales;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  BluetoothReceiptService get receiptService => _receiptService;

  // Set current user (to be called from AuthProvider when user logs in)
  void setCurrentUser(User? user) {
    _currentUser = user;
    debugPrint('SalesProvider: Current user set to: ${user?.fullName ?? 'null'}');
  }

  // Load sales from database
  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _queuedSales = await _databaseHelper.getQueuedSales();
      _syncedSales = await _databaseHelper.getSyncedSales();
      
      // Clean up old synced sales
      await _databaseHelper.cleanupOldSyncedSales();
      
      debugPrint('SalesProvider: Loaded ${_queuedSales.length} queued sales and ${_syncedSales.length} synced sales');
    } catch (e) {
      debugPrint('SalesProvider: Error loading sales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new sale
  Future<bool> addSale({
    required List<SaleItem> items,
    required String currency,
    String? notes,
  }) async {
    if (items.isEmpty) {
      debugPrint('SalesProvider: Cannot create sale with empty items');
      return false;
    }

    try {
      debugPrint('SalesProvider: Starting sale creation with ${items.length} items');
      
      // Validate items
      if (items.isEmpty) {
        debugPrint('SalesProvider: ERROR - No items provided');
        return false;
      }
      
      for (var item in items) {
        debugPrint('SalesProvider: Item: ${item.productName}, Qty: ${item.quantityInUnits}, Price: \$${item.totalPrice}');
      }
      
      // Calculate total amount
      double totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      debugPrint('SalesProvider: Calculated total amount: \$${totalAmount.toStringAsFixed(2)}');
      
      // Create sale with unique ID
      final sale = Sale(
        id: 'SALE_${DateTime.now().millisecondsSinceEpoch}',
        dateOfSale: DateTime.now(),
        currency: currency,
        department: 'Butchery',
        notes: notes,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        isQueued: true,
        items: items,
      );

      debugPrint('SalesProvider: Created sale object: ${sale.id}');
      debugPrint('SalesProvider: Sale toMap: ${sale.toMap()}');

      // Store locally first
      debugPrint('SalesProvider: Attempting to store sale in local database...');
      await _databaseHelper.insertQueuedSale(sale);
      debugPrint('SalesProvider: ✅ Sale stored successfully in local database');
      
      // Add to local list
      _queuedSales.insert(0, sale);
      notifyListeners();
      debugPrint('SalesProvider: ✅ Sale added to local list and UI notified');

      // Auto-print receipt if user is logged in and printer is connected
      await _autoPrintReceipt(sale);

      // Try to sync to API in background
      debugPrint('SalesProvider: Starting background API sync...');
      _syncSaleInBackground(sale.id);

      debugPrint('SalesProvider: ✅ Sale creation completed successfully');
      return true;
    } catch (e) {
      debugPrint('SalesProvider: Error creating sale: $e');
      return false;
    }
  }

  // Auto-print receipt if conditions are met
  Future<void> _autoPrintReceipt(Sale sale) async {
    try {
      // Check if we have a current user (cashier)
      if (_currentUser == null) {
        debugPrint('⚠️ Cannot print receipt: No current user set');
        return;
      }

      // Try to auto-connect to printer if not connected
      if (!_receiptService.isConnected) {
        debugPrint('🔍 Attempting to auto-connect to Bluetooth printer...');
        final connected = await _receiptService.autoConnect();
        
        if (!connected) {
          debugPrint('⚠️ Cannot print receipt: No Bluetooth printer connected');
          return;
        }
      }

      // Print the receipt
      debugPrint('🖨️ Auto-printing receipt for sale ${sale.id}...');
      final success = await _receiptService.printReceipt(
        sale: sale,
        cashier: _currentUser!,
      );

      if (success) {
        debugPrint('✅ Receipt auto-printed successfully!');
      } else {
        debugPrint('❌ Failed to auto-print receipt');
      }
    } catch (e) {
      debugPrint('❌ Error auto-printing receipt: $e');
    }
  }

  // Manually print receipt for a specific sale
  Future<bool> printReceipt(String saleId) async {
    try {
      // Find the sale
      Sale? sale;
      
      // Look in queued sales first
      try {
        sale = _queuedSales.firstWhere((s) => s.id == saleId);
      } catch (e) {
        // Try synced sales
        try {
          sale = _syncedSales.firstWhere((s) => s.id == saleId);
        } catch (e) {
          debugPrint('❌ Sale $saleId not found');
          return false;
        }
      }

      if (_currentUser == null) {
        debugPrint('❌ Cannot print receipt: No current user');
        return false;
      }

      if (!_receiptService.isConnected) {
        debugPrint('❌ Cannot print receipt: No printer connected');
        return false;
      }

      return await _receiptService.printReceipt(
        sale: sale,
        cashier: _currentUser!,
      );
    } catch (e) {
      debugPrint('❌ Error printing receipt: $e');
      return false;
    }
  }

  // Sync a specific sale to API
  Future<void> _syncSaleInBackground(String saleId) async {
    try {
      final sale = _queuedSales.firstWhere((s) => s.id == saleId);
      
      final success = await _salesService.addSale(sale);
      
      if (success) {
        // Move from queued to synced
        await _databaseHelper.moveSaleToSynced(saleId);
        
        // Update local lists
        _queuedSales.removeWhere((s) => s.id == saleId);
        
        // Add to synced sales (will be loaded on next refresh)
        await loadSales();
        
        debugPrint('SalesProvider: Sale $saleId successfully synced');
      } else {
        debugPrint('SalesProvider: Failed to sync sale $saleId, will retry later');
      }
    } catch (e) {
      debugPrint('SalesProvider: Error syncing sale $saleId: $e');
    }
  }

  // Sync all queued sales
  Future<void> syncAllQueuedSales() async {
    debugPrint('SalesProvider: Syncing ${_queuedSales.length} queued sales');
    
    for (var sale in List.from(_queuedSales)) {
      await _syncSaleInBackground(sale.id);
      
      // Small delay between syncs to avoid overwhelming the API
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Create sale item from product and quantity
  SaleItem createSaleItem({
    required Product product,
    required double quantity,
  }) {
    final totalPrice = quantity * product.pricePerUnit;
    
    return SaleItem(
      productId: product.productId,
      productName: product.productName,
      quantityInUnits: quantity,
      pricePerUnit: product.pricePerUnit,
      totalPrice: totalPrice,
    );
  }

  // Get sales summary
  Map<String, dynamic> getSalesSummary() {
    final queuedTotal = _queuedSales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    final syncedTotal = _syncedSales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    
    return {
      'queuedCount': _queuedSales.length,
      'queuedTotal': queuedTotal,
      'syncedCount': _syncedSales.length,
      'syncedTotal': syncedTotal,
      'totalSales': queuedTotal + syncedTotal,
    };
  }
}