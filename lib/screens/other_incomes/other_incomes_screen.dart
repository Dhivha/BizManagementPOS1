import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/other_income.dart';
import '../../providers/other_income_provider.dart';
import '../../utils/app_theme.dart';
import 'add_other_income_screen.dart';

class OtherIncomesScreen extends StatefulWidget {
  const OtherIncomesScreen({super.key});

  @override
  State<OtherIncomesScreen> createState() => _OtherIncomesScreenState();
}

class _OtherIncomesScreenState extends State<OtherIncomesScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOtherIncomes();
    });
  }

  Future<void> _loadOtherIncomes() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final otherIncomeProvider = Provider.of<OtherIncomeProvider>(context, listen: false);
    await otherIncomeProvider.loadOtherIncomes();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildIncomeCard(OtherIncome income) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.gold,
          child: const Icon(
            Icons.attach_money,
            color: Colors.white,
          ),
        ),
        title: Text(
          '\$${income.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${income.category}'),
            Text('Narration: ${income.narration}'),
            Text('Date: ${income.dateTimeCaptured.toLocal().toString().split('.')[0]}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Incomes'),
        backgroundColor: AppTheme.gold,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<OtherIncomeProvider>(
              builder: (context, otherIncomeProvider, child) {
                if (otherIncomeProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${otherIncomeProvider.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOtherIncomes,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final otherIncomes = otherIncomeProvider.otherIncomes;

                if (otherIncomes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.attach_money, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No other incomes yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Tap the + button to add income'),
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
                          const Text('Total Other Incomes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('\$${otherIncomeProvider.totalAmount.toStringAsFixed(2)}', 
                               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.gold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadOtherIncomes,
                        child: ListView.builder(
                          itemCount: otherIncomes.length,
                          itemBuilder: (context, index) {
                            return _buildIncomeCard(otherIncomes[index]);
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
            MaterialPageRoute(builder: (context) => const AddOtherIncomeScreen()),
          ).then((_) => _loadOtherIncomes());
        },
        backgroundColor: AppTheme.gold,
        icon: const Icon(Icons.add),
        label: const Text('Capture Income'),
      ),
    );
  }
}
