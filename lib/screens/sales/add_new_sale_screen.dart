import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_theme.dart';

class AddNewSaleScreen extends StatefulWidget {
  const AddNewSaleScreen({super.key});

  @override
  State<AddNewSaleScreen> createState() => _AddNewSaleScreenState();
}

class _AddNewSaleScreenState extends State<AddNewSaleScreen> {
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final List<SaleItem> _saleItems = [];
  String _selectedCurrency = 'USD';
  List<Product> _filteredProducts = [];
  List<Product> _allProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.initializeProducts();
    
    setState(() {
      _allProducts = productProvider.products;
      _filteredProducts = _allProducts;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) =>
          product.productName.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  void _showQuantityDialog(Product product) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${product.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price per ${product.unit}: \$${product.pricePerUnit.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Quantity (${product.unit})',
                hintText: 'Enter quantity (e.g., 1.5)',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                _addSaleItem(product, quantity);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid quantity')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addSaleItem(Product product, double quantity) {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final saleItem = salesProvider.createSaleItem(
      product: product,
      quantity: quantity,
    );
    
    setState(() {
      // Check if product already exists in the sale
      final existingIndex = _saleItems.indexWhere((item) => item.productId == product.productId);
      
      if (existingIndex != -1) {
        // Update existing item quantity
        final existing = _saleItems[existingIndex];
        final newQuantity = existing.quantityInUnits + quantity;
        final newTotalPrice = newQuantity * existing.pricePerUnit;
        
        _saleItems[existingIndex] = SaleItem(
          productId: existing.productId,
          productName: existing.productName,
          quantityInUnits: newQuantity,
          pricePerUnit: existing.pricePerUnit,
          totalPrice: newTotalPrice,
        );
      } else {
        // Add new item
        _saleItems.add(saleItem);
      }
    });
  }

  void _removeSaleItem(int index) {
    setState(() {
      _saleItems.removeAt(index);
    });
  }

  double _getTotalAmount() {
    return _saleItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _completeSale() async {
    if (_saleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to the sale')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    
    final success = await salesProvider.addSale(
      items: _saleItems,
      currency: _selectedCurrency,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.gold, size: 32),
                const SizedBox(width: 12),
                const Text('Success'),
              ],
            ),
            content: Text('Sale completed successfully! Total: \$${_getTotalAmount().toStringAsFixed(2)}'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        // Clear the form
        setState(() {
          _saleItems.clear();
          _notesController.clear();
          _selectedCurrency = 'USD';
        });
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Text('Error'),
              ],
            ),
            content: const Text('Failed to save sale'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Sale'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency selector
            Row(
              children: [
                const Text('Currency: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                DropdownButton<String>(
                  value: _selectedCurrency,
                  items: ['USD', 'ZWD'].map((currency) => DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value!;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notes field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // Product search
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Products',
                hintText: 'Search by name or category...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Products list
            Expanded(
              flex: 2,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Available Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return ListTile(
                            title: Text(product.productName),
                            subtitle: Text('${product.category} • \$${product.pricePerUnit.toStringAsFixed(2)}/${product.unit}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () => _showQuantityDialog(product),
                            ),
                            onTap: () => _showQuantityDialog(product),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sale items
            Expanded(
              flex: 2,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sale Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Total: \$${_getTotalAmount().toStringAsFixed(2)}', 
                               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _saleItems.isEmpty
                          ? const Center(child: Text('No items added yet'))
                          : ListView.builder(
                              itemCount: _saleItems.length,
                              itemBuilder: (context, index) {
                                final item = _saleItems[index];
                                return ListTile(
                                  title: Text(item.productName),
                                  subtitle: Text('Qty: ${item.quantityInUnits} • \$${item.pricePerUnit.toStringAsFixed(2)} each'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('\$${item.totalPrice.toStringAsFixed(2)}', 
                                           style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () => _removeSaleItem(index),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Complete sale button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _saleItems.isEmpty ? null : _completeSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text('Complete Sale - \$${_getTotalAmount().toStringAsFixed(2)}', 
                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}