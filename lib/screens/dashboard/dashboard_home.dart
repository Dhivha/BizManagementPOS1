// Dashboard Home Widget
import 'dart:async';

import 'package:bizmanagement/providers/auth_provider.dart';
import 'package:bizmanagement/providers/bulk_sales_provider.dart';
import 'package:bizmanagement/providers/expense_provider.dart';
import 'package:bizmanagement/providers/other_income_provider.dart';
import 'package:bizmanagement/providers/product_provider.dart';
import 'package:bizmanagement/providers/purchases_provider.dart';
import 'package:bizmanagement/screens/expenses/expenses_list_screen.dart';
import 'package:bizmanagement/screens/other_incomes/other_incomes_screen.dart';
import 'package:bizmanagement/screens/products/products_screen.dart';
import 'package:bizmanagement/screens/purchases/purchases_screen.dart';
import 'package:bizmanagement/screens/sales/sales_main_screen.dart';
import 'package:bizmanagement/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardHomeWidget extends StatefulWidget {
  const DashboardHomeWidget({super.key});

  @override
  State<DashboardHomeWidget> createState() => _DashboardHomeWidgetState();
}

class _DashboardHomeWidgetState extends State<DashboardHomeWidget> {
  double _totalSales = 0.0;
  double _totalPurchases = 0.0;
  double _totalOtherIncomes = 0.0;
  double _totalExpenses = 0.0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initializeProducts();
      _loadSalesData();
      _loadPurchasesData();
      _loadOtherIncomesData();
      _loadExpensesData();
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _loadSalesData();
        _loadPurchasesData();
        _loadOtherIncomesData();
        _loadExpensesData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSalesData() async {
    if (!mounted) return;

    try {
      final bulkSalesProvider = context.read<BulkSalesProvider>();
      final total = await bulkSalesProvider.getTotalSalesAmount();

      if (mounted) {
        setState(() {
          _totalSales = total;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalSales = 0.0;
        });
      }
    }
  }

  Future<void> _loadPurchasesData() async {
    if (!mounted) return;

    try {
      final purchasesProvider = context.read<PurchasesProvider>();
      await purchasesProvider.loadPurchases();

      if (mounted) {
        setState(() {
          _totalPurchases = purchasesProvider.totalPurchasesInvoiceAmount;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalPurchases = 0.0;
        });
      }
    }
  }

  Future<void> _loadOtherIncomesData() async {
    if (!mounted) return;

    try {
      final otherIncomeProvider = context.read<OtherIncomeProvider>();
      await otherIncomeProvider.loadOtherIncomes();

      if (mounted) {
        setState(() {
          _totalOtherIncomes = otherIncomeProvider.totalAmount;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalOtherIncomes = 0.0;
        });
      }
    }
  }

  Future<void> _loadExpensesData() async {
    if (!mounted) return;

    try {
      final expenseProvider = context.read<ExpenseProvider>();
      await expenseProvider.loadAllExpenses();

      if (mounted) {
        setState(() {
          _totalExpenses = expenseProvider.totalAmount;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalExpenses = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Subtle gradient background
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Colors.white,
            //     AppTheme.backgroundDark,
            //   ],
            // ),
          ),
        ),

        // Main content
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.gold,
                                  AppTheme.darkGold,
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppTheme.primaryNavy,
                              child: Text(
                                authProvider.user?.fullName
                                        .substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.gold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${authProvider.user?.fullName ?? 'User'}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '@${authProvider.user?.username ?? 'user'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Stats Section Header
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Sales',
                      '\$${_totalSales.toStringAsFixed(2)}',
                      Icons.point_of_sale,
                      Colors.green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SalesMainScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Purchases',
                      '\$${_totalPurchases.toStringAsFixed(2)}',
                      Icons.shopping_cart,
                      Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PurchasesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Expenses',
                      '\$${_totalExpenses.toStringAsFixed(2)}',
                      Icons.money_off,
                      Colors.red,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ExpensesListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Other Incomes',
                      '\$${_totalOtherIncomes.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.orange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const OtherIncomesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                        return _buildStatCard(
                          'Products',
                          '${productProvider.allProducts.length}',
                          Icons.inventory,
                          Colors.purple,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProductsScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: color.withOpacity(0.3),
        //     blurRadius: 20,
        //     spreadRadius: 2,
        //     offset: const Offset(0, 8),
        //   ),
        // ],
      ),
      child: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     color.withOpacity(0.15),
          //     color.withOpacity(0.05),
          //   ],
          // ),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      if (onTap != null)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white70,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
