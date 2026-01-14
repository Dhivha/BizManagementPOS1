import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({super.key});

  @override
  State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  Future<void> _loadExpenses() async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    await expenseProvider.loadExpensesByCategory('Butchery');
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _applyFilter() {
    if (_startDate == null || _endDate == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please select both start and end dates'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Start date must be before end date'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.filterByDateRange(_startDate!, _endDate!);
    setState(() {
      _isFilterApplied = true;
    });
  }

  void _clearFilter() {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.clearFilter();
    setState(() {
      _startDate = null;
      _endDate = null;
      _isFilterApplied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Expenses'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Date Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _startDate == null
                                      ? 'Start Date'
                                      : DateFormat('yyyy-MM-dd').format(_startDate!),
                                  style: TextStyle(
                                    color: _startDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                const Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endDate == null
                                      ? 'End Date'
                                      : DateFormat('yyyy-MM-dd').format(_endDate!),
                                  style: TextStyle(
                                    color: _endDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                const Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _applyFilter,
                          icon: const Icon(Icons.filter_alt),
                          label: const Text('Apply Filter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                      if (_isFilterApplied) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _clearFilter,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Filter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: expenseProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : expenseProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${expenseProvider.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadExpenses,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : expenseProvider.filteredExpenses.isEmpty
                        ? const Center(
                            child: Text(
                              'No expenses found',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: expenseProvider.filteredExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = expenseProvider.filteredExpenses[index];
                              return _buildExpenseCard(expense);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor(expense.paymentMethod),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    expense.paymentMethod,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.category, 'Category', expense.category),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.description, 'Narration', expense.narration),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.notes, 'Notes', expense.notes),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Expense Date',
              DateFormat('yyyy-MM-dd').format(expense.expenseDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.person,
              'User',
              '${expense.userFirstName} ${expense.userLastName}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Created At',
              DateFormat('yyyy-MM-dd HH:mm').format(expense.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return const Color(0xFF4CAF50);
      case 'bank':
        return const Color(0xFF1976D2);
      case 'credit':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }
}
