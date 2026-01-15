import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../utils/app_theme.dart';
import 'capture_expense_screen.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  Future<void> _loadExpenses() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    await expenseProvider.loadAllExpenses();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.gold,
          child: const Icon(
            Icons.money_off,
            color: Colors.white,
          ),
        ),
        title: Text(
          '\$${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${expense.category}'),
            Text('Narration: ${expense.narration}'),
            Text('Payment: ${expense.paymentMethod}'),
            Text('Date: ${expense.expenseDate.toLocal().toString().split('.')[0]}'),
            if (expense.notes.isNotEmpty) Text('Notes: ${expense.notes}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: AppTheme.gold,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, child) {
                if (expenseProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${expenseProvider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadExpenses,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final expenses = expenseProvider.expenses;

                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.money_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No expenses yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Tap the + button to add an expense'),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppTheme.gold.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Expenses:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('\$${expenseProvider.totalAmount.toStringAsFixed(2)}', 
                               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.gold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadExpenses,
                        child: ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            return _buildExpenseCard(expenses[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CaptureExpenseScreen()),
          ).then((_) => _loadExpenses());
        },
        backgroundColor: AppTheme.gold,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
