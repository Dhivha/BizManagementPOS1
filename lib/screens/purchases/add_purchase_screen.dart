import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/purchase.dart';
import '../../models/product.dart';
import '../../providers/purchases_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_theme.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _invoiceAmountController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['USD', 'ZWD'];

  final List<PurchaseItemForm> _items = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _invoiceAmountController.dispose();
    _amountPaidController.dispose();
    _expensesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(PurchaseItemForm());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    // Validate all items
    for (var item in _items) {
      if (item.selectedProduct == null || item.quantityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all item fields')),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final request = CreatePurchaseRequest(
        dateOfPurchases: DateTime.now(),
        purchasesInvoiceAmount: double.parse(_invoiceAmountController.text),
        currency: _selectedCurrency,
        amountPaid: double.parse(_amountPaidController.text),
        purchasesExpenses: double.parse(_expensesController.text),
        department: 'Butchery',
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        items: _items.map((item) {
          return CreatePurchaseItemRequest(
            productId: item.selectedProduct!.productId,
            quantityInUnits: double.parse(item.quantityController.text),
            unitCost: 1.0, // As per requirements
          );
        }).toList(),
      );

      await Provider.of<PurchasesProvider>(context, listen: false).addPurchase(request);

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
            content: const Text('Purchase added successfully'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
      }
    } catch (e) {
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
            content: Text('Failed to add purchase: $e'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture New Purchase'),
        backgroundColor: AppTheme.gold,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Purchase Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.gold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _invoiceAmountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Invoice Amount',
                                    prefixText: '\$ ',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCurrency,
                                  decoration: const InputDecoration(
                                    labelText: 'Currency',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _currencies.map((currency) {
                                    return DropdownMenuItem(
                                      value: currency,
                                      child: Text(currency),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCurrency = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _amountPaidController,
                                  decoration: const InputDecoration(
                                    labelText: 'Amount Paid',
                                    prefixText: '\$ ',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _expensesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Expenses',
                                    prefixText: '\$ ',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Purchase Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.gold)),
                              ElevatedButton.icon(
                                onPressed: _addItem,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Item'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.gold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_items.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No items added yet. Click "Add Item" to begin.', 
                                            style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ..._items.asMap().entries.map((entry) {
                              int index = entry.key;
                              PurchaseItemForm item = entry.value;
                              return _buildItemForm(index, item);
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _savePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Save Purchase'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildItemForm(int index, PurchaseItemForm item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final products = productProvider.allProducts;
                
                return Autocomplete<Product>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Product>.empty();
                    }
                    return products.where((Product product) {
                      return product.productName
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()) ||
                          product.productId
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Product product) => product.productName,
                  onSelected: (Product product) {
                    setState(() {
                      item.selectedProduct = product;
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'Search product...',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      validator: (value) {
                        if (item.selectedProduct == null) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final product = options.elementAt(index);
                              return ListTile(
                                title: Text(product.productName),
                                subtitle: Text(product.productId),
                                onTap: () => onSelected(product),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            if (item.selectedProduct != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Product ID: ${item.selectedProduct!.productId}', 
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: item.quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity in Units',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseItemForm {
  Product? selectedProduct;
  final TextEditingController quantityController = TextEditingController();

  void dispose() {
    quantityController.dispose();
  }
}
