import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sale.dart';
import '../models/user.dart';

class BluetoothReceiptService {
  static final BluetoothReceiptService _instance = BluetoothReceiptService._internal();
  factory BluetoothReceiptService() => _instance;
  BluetoothReceiptService._internal();

  // Mock Bluetooth device for compatibility
  MockBluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  List<MockBluetoothDevice> _devices = [];

  bool get isConnected => _isConnected;
  MockBluetoothDevice? get connectedDevice => _connectedDevice;
  List<MockBluetoothDevice> get devices => _devices;

  // Scan for mock devices (for UI compatibility)
  Future<List<MockBluetoothDevice>> scanForDevices() async {
    try {
      debugPrint('🔍 Scanning for receipt printers...');
      
      // Simulate finding devices
      _devices = [
        MockBluetoothDevice(name: 'Receipt Printer Simulator', address: 'SIM:00:00:00:00:01'),
        MockBluetoothDevice(name: 'File System Printer', address: 'FILE:00:00:00:00:01'),
      ];
      
      debugPrint('✅ Found ${_devices.length} receipt printers (file-based)');
      return _devices;
    } catch (e) {
      debugPrint('❌ Error scanning for devices: $e');
      return [];
    }
  }

  // Connect to a mock device
  Future<bool> connectToDevice(MockBluetoothDevice device) async {
    try {
      debugPrint('🔗 Connecting to device: ${device.name}');
      
      _connectedDevice = device;
      _isConnected = true;
      
      debugPrint('✅ Connected to ${device.name} (file-based receipt printing enabled)');
      return true;
    } catch (e) {
      debugPrint('❌ Error connecting to device: $e');
      _isConnected = false;
      _connectedDevice = null;
      return false;
    }
  }

  // Auto-connect to first available device
  Future<bool> autoConnect() async {
    try {
      debugPrint('🔍 Auto-connecting to receipt printer...');
      
      if (_isConnected) {
        debugPrint('✅ Already connected');
        return true;
      }

      final devices = await scanForDevices();
      if (devices.isEmpty) {
        debugPrint('❌ No receipt printers found');
        return false;
      }

      // Auto-connect to the first device
      return await connectToDevice(devices.first);
    } catch (e) {
      debugPrint('❌ Error auto-connecting: $e');
      return false;
    }
  }

  // Disconnect from current device
  Future<void> disconnect() async {
    try {
      if (_isConnected) {
        debugPrint('✅ Disconnected from receipt printer');
      }
    } catch (e) {
      debugPrint('❌ Error disconnecting: $e');
    } finally {
      _isConnected = false;
      _connectedDevice = null;
    }
  }

  // Print receipt for a sale (save to file)
  Future<bool> printReceipt({
    required Sale sale,
    required User cashier,
  }) async {
    try {
      debugPrint('🖨️ Generating receipt for sale ${sale.id}...');

      // Generate receipt content
      String receiptText = _generateReceiptText(sale: sale, cashier: cashier);
      
      // Save to file
      bool saved = await _saveReceiptToFile(sale.id, receiptText);
      
      if (saved) {
        debugPrint('✅ Receipt generated and saved successfully');
        return true;
      } else {
        debugPrint('❌ Failed to save receipt');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error generating receipt: $e');
      return false;
    }
  }

  // Save receipt to file
  Future<bool> _saveReceiptToFile(String saleId, String receiptText) async {
    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${directory.path}/receipts');
      
      // Create receipts directory if it doesn't exist
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      // Create receipt file
      final receiptFile = File('${receiptsDir.path}/receipt_$saleId.txt');
      await receiptFile.writeAsString(receiptText);
      
      debugPrint('📄 Receipt saved to: ${receiptFile.path}');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving receipt to file: $e');
      return false;
    }
  }

  // Generate receipt text
  String _generateReceiptText({
    required Sale sale,
    required User cashier,
  }) {
    // Zimbabwe timezone is UTC+2
    final receiptTime = DateTime.now().add(const Duration(hours: 2));
    
    StringBuffer receipt = StringBuffer();
    
    // Store header
    receipt.writeln("========================================");
    receipt.writeln("           BUSINESS RECEIPT             ");
    receipt.writeln("========================================");
    
    // Date and time
    String formattedDate = "${receiptTime.day.toString().padLeft(2, '0')}/"
        "${receiptTime.month.toString().padLeft(2, '0')}/"
        "${receiptTime.year}";
    String formattedTime = "${receiptTime.hour.toString().padLeft(2, '0')}:"
        "${receiptTime.minute.toString().padLeft(2, '0')}:"
        "${receiptTime.second.toString().padLeft(2, '0')}";
    
    receipt.writeln("Date: $formattedDate");
    receipt.writeln("Time: $formattedTime (Zimbabwe UTC+2)");
    receipt.writeln("Receipt #: ${sale.id}");
    receipt.writeln("Cashier: ${cashier.firstName} ${cashier.lastName}");
    receipt.writeln("========================================");
    
    // Items section
    receipt.writeln("ITEMS PURCHASED:");
    receipt.writeln("----------------------------------------");
    
    double total = 0.0;
    for (int i = 0; i < sale.items.length; i++) {
      var item = sale.items[i];
      double itemTotal = item.quantityInUnits * item.pricePerUnit;
      total += itemTotal;
      
      receipt.writeln("${i + 1}. ${item.productName}");
      receipt.writeln("   Qty: ${item.quantityInUnits} x \$${item.pricePerUnit.toStringAsFixed(2)} = \$${itemTotal.toStringAsFixed(2)}");
      receipt.writeln();
    }
    
    // Total section
    receipt.writeln("----------------------------------------");
    receipt.writeln("TOTAL: \$${total.toStringAsFixed(2)}");
    
    receipt.writeln("----------------------------------------");
    
    // Totals
    receipt.writeln("SUBTOTAL: \$${sale.totalAmount.toStringAsFixed(2)}");
    receipt.writeln("TOTAL: \$${sale.totalAmount.toStringAsFixed(2)}");
    receipt.writeln("========================================");
    
    // Payment information - using generic payment info since specific fields aren't in Sale model
    receipt.writeln("PAYMENT DETAILS:");
    receipt.writeln("Payment Method: Cash"); // Default since no payment method in Sale model
    receipt.writeln("Total Amount: \$${sale.totalAmount.toStringAsFixed(2)}");
    receipt.writeln("Transaction Completed Successfully");
    
    receipt.writeln("========================================");
    receipt.writeln("       Thank you for your business!     ");
    receipt.writeln("         Please come again soon!        ");
    receipt.writeln("========================================");
    
    // Receipt metadata
    receipt.writeln();
    receipt.writeln("Receipt generated: ${DateTime.now()}");
    receipt.writeln("Generated by: BizManagement App v1.0.0");
    
    return receipt.toString();
  }

  // Auto-print if enabled and conditions are met
  Future<void> autoPrintIfEnabled({
    required Sale sale,
    required User cashier,
  }) async {
    try {
      debugPrint('🔍 Checking auto-print conditions...');
      
      // Try to auto-connect if not connected
      if (!_isConnected) {
        debugPrint('🔗 Attempting auto-connect for receipt generation...');
        final connected = await autoConnect();
        if (!connected) {
          debugPrint('⚠️ Auto-print skipped: No receipt printer available');
          return;
        }
      }

      // Generate and save the receipt
      final success = await printReceipt(sale: sale, cashier: cashier);
      if (success) {
        debugPrint('✅ Receipt auto-generated successfully');
      } else {
        debugPrint('❌ Auto-receipt generation failed');
      }
    } catch (e) {
      debugPrint('❌ Error in auto-receipt generation: $e');
    }
  }
}

// Mock Bluetooth device class for compatibility
class MockBluetoothDevice {
  final String name;
  final String address;

  MockBluetoothDevice({required this.name, required this.address});

  @override
  String toString() => 'MockBluetoothDevice(name: $name, address: $address)';
}