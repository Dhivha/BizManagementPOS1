import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bulk_sales_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class AddBulkSaleScreen extends StatefulWidget {
  const AddBulkSaleScreen({super.key});

  @override
  State<AddBulkSaleScreen> createState() => _AddBulkSaleScreenState();
}

class _AddBulkSaleScreenState extends State<AddBulkSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  String _selectedCategory = 'Butchery';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitBulkSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);

    if (!mounted) return;
    final bulkSalesProvider = Provider.of<BulkSalesProvider>(context, listen: false);

    final result = await bulkSalesProvider.addBulkSale(
      dateOfSale: DateTime.now(),
      category: _selectedCategory,
      amount: amount,
      capturedBy: user.fullName,
    );

    if (!mounted) return;

    if (result['success']) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: Text(result['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(result['message']),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bulkSalesProvider = Provider.of<BulkSalesProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Bulk Sale',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryNavy,
              AppTheme.primaryNavy.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
                  ),
                  color: AppTheme.primaryNavy,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gold.withValues(alpha: 0.1),
                          AppTheme.gold.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: AppTheme.primaryNavy,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.gold, width: 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(
                              value: 'Butchery',
                              child: Text('Butchery', style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'Butchery and Other',
                              child: Text('Butchery and Other', style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
                  ),
                  color: AppTheme.primaryNavy,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gold.withValues(alpha: 0.1),
                          AppTheme.gold.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.gold, width: 2),
                            ),
                            prefixText: '\$ ',
                            prefixStyle: const TextStyle(color: AppTheme.gold),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: bulkSalesProvider.isLoading ? null : _submitBulkSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: AppTheme.primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: bulkSalesProvider.isLoading
                        ? const CircularProgressIndicator(color: AppTheme.primaryNavy)
                        : const Text(
                            'Submit Bulk Sale',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
