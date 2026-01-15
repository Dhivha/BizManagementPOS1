import 'package:flutter/material.dart';
import 'capture_expense_screen.dart';
import 'view_expenses_screen.dart';
import '../../utils/app_theme.dart';

class ExpensesDashboard extends StatelessWidget {
  const ExpensesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDashboardCard(
                context,
                title: 'Capture Expense',
                icon: Icons.add_circle_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CaptureExpenseScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDashboardCard(
                context,
                title: 'View Expenses',
                icon: Icons.list_alt,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewExpensesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      color: AppTheme.primaryNavy,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                AppTheme.gold.withValues(alpha: 0.1),
                AppTheme.gold.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppTheme.gold),
            ],
          ),
        ),
      ),
    );
  }
}
