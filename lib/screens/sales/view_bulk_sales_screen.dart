import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/bulk_sales_provider.dart';
import '../../utils/app_theme.dart';

class ViewBulkSalesScreen extends StatefulWidget {
  const ViewBulkSalesScreen({super.key});

  @override
  State<ViewBulkSalesScreen> createState() => _ViewBulkSalesScreenState();
}

class _ViewBulkSalesScreenState extends State<ViewBulkSalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BulkSalesProvider>(context, listen: false).loadBulkSales();
    });
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
          'Bulk Sales',
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
        child: bulkSalesProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
            : bulkSalesProvider.bulkSales.isEmpty
                ? const Center(
                    child: Text(
                      'No bulk sales found',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                : RefreshIndicator(
                    color: AppTheme.gold,
                    onRefresh: () => bulkSalesProvider.loadBulkSales(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: bulkSalesProvider.bulkSales.length,
                      itemBuilder: (context, index) {
                        final bulkSale = bulkSalesProvider.bulkSales[index];
                        return Card(
                          elevation: 8,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
                          ),
                          color: AppTheme.primaryNavy,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('yyyy-MM-dd').format(bulkSale.dateOfSale),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.gold,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        bulkSale.category,
                                        style: const TextStyle(
                                          color: AppTheme.primaryNavy,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Amount:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    Text(
                                      '\$${bulkSale.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.gold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Captured By:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    Text(
                                      bulkSale.capturedBy,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                if (bulkSale.createdAt != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(bulkSale.createdAt!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
