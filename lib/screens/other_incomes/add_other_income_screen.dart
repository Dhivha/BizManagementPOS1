import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/other_income.dart';
import '../../providers/other_income_provider.dart';
import '../../utils/app_theme.dart';

class AddOtherIncomeScreen extends StatefulWidget {
  const AddOtherIncomeScreen({super.key});

  @override
  State<AddOtherIncomeScreen> createState() => _AddOtherIncomeScreenState();
}

class _AddOtherIncomeScreenState extends State<AddOtherIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveOtherIncome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final request = CreateOtherIncomeRequest(
        dateTimeCaptured: DateTime.now(),
        amount: double.parse(_amountController.text),
        narration: _narrationController.text,
        category: _categoryController.text,
        department: 'Butchery',
      );

      await Provider.of<OtherIncomeProvider>(context, listen: false).createOtherIncome(request);

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
            content: const Text('Other income added successfully'),
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
            content: Text('Failed to add income: $e'),
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
        title: const Text('Capture Income'),
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
                          Text('Income Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.gold)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _narrationController,
                            decoration: const InputDecoration(
                              labelText: 'Narration',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveOtherIncome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Save Income'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
