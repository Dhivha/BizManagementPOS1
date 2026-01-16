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

    final otherIncomeProvider =
        Provider.of<OtherIncomeProvider>(context, listen: false);
    await otherIncomeProvider.loadOtherIncomes();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildIncomeCard(OtherIncome income) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor:
                AppTheme.primaryNavy.withValues(alpha: 0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
            ),
          ),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.gold,
                child: const Icon(Icons.attach_money,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${income.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                    Text(
                      income.category,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Narration:',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                      Text(income.narration,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Date:',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                      Text(
                          income.dateTimeCaptured
                              .toLocal()
                              .toString()
                              .split('.')[0],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title:
            const Text('Other Incomes', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryNavy,
        centerTitle: true,
        elevation: 0,
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
                        Icon(Icons.attach_money,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('No other incomes yet',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.5))),
                        const SizedBox(height: 8),
                        Text('Tap the + button to add income',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4))),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.gold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Other Incomes:',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.9))),
                          Text(
                              '\$${otherIncomeProvider.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.gold)),
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
            MaterialPageRoute(
                builder: (context) => const AddOtherIncomeScreen()),
          ).then((_) => _loadOtherIncomes());
        },
        backgroundColor: AppTheme.gold,
        icon: const Icon(Icons.add),
        label: const Text('Capture Income'),
      ),
    );
  }
}
