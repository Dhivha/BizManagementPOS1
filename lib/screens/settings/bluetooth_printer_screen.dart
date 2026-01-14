import 'package:flutter/material.dart';
import '../../services/bluetooth_receipt_service.dart';

class BluetoothPrinterScreen extends StatefulWidget {
  const BluetoothPrinterScreen({super.key});

  @override
  State<BluetoothPrinterScreen> createState() => _BluetoothPrinterScreenState();
}

class _BluetoothPrinterScreenState extends State<BluetoothPrinterScreen> {
  final BluetoothReceiptService _receiptService = BluetoothReceiptService();
  List<MockBluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
    _scanForDevices();
  }

  void _checkConnectionStatus() {
    setState(() {
      _isConnected = _receiptService.isConnected;
    });
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final devices = await _receiptService.scanForDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      _showSnackBar('Error scanning for devices: $e', Colors.red);
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(MockBluetoothDevice device) async {
    try {
      bool connected = await _receiptService.connectToDevice(device);
      
      if (connected) {
        setState(() {
          _isConnected = true;
        });
        _showSnackBar('Connected to ${device.name}', Colors.green);
      } else {
        _showSnackBar('Failed to connect to ${device.name}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error connecting: $e', Colors.red);
    }
  }

  Future<void> _disconnect() async {
    await _receiptService.disconnect();
    setState(() {
      _isConnected = false;
    });
    _showSnackBar('Disconnected from receipt printer', Colors.orange);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Printer'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForDevices,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Receipt Printer Setup',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app generates text-based receipts that are saved to your device\'s Documents folder. '
                      'Receipts will be automatically generated when sales are completed and can be found in the receipts folder.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Connection Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.receipt_long : Icons.receipt_outlined,
                      color: _isConnected ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receipt Generator Status',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _isConnected ? 'Active - Receipts will be generated automatically' : 'Inactive - Connect to enable auto-receipts',
                            style: TextStyle(
                              color: _isConnected ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isConnected && _receiptService.connectedDevice != null)
                            Text(
                              'Using: ${_receiptService.connectedDevice!.name}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isConnected)
                      ElevatedButton(
                        onPressed: _disconnect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Disable'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Available Devices Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Receipt Generators',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_isScanning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Devices List
            Expanded(
              child: _devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isScanning 
                                ? 'Initializing receipt generators...' 
                                : 'No receipt generators found',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          if (!_isScanning) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _scanForDevices,
                              child: const Text('Scan Again'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        final isCurrentDevice = _receiptService.connectedDevice?.address == device.address;
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              Icons.receipt_long,
                              color: isCurrentDevice ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              device.name,
                              style: TextStyle(
                                fontWeight: isCurrentDevice ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: const Text('File-based receipt generation'),
                            trailing: isCurrentDevice
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () => _connectToDevice(device),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Enable'),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Footer info
            if (_isConnected) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Auto-receipts enabled! Receipts will be generated automatically when sales are completed.',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}