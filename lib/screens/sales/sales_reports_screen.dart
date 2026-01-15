import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';
import '../../utils/app_theme.dart';

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({super.key});

  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    await salesProvider.loadSales();

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 8,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppTheme.gold),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Sales Reports'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _loadReports,
          ),
        ],
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
            : Consumer<SalesProvider>(
                builder: (context, salesProvider, child) {
                  final summary = salesProvider.getSalesSummary();
                  
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sales Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Summary cards
                        Expanded(
                          flex: 2,
                          child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildSummaryCard(
                                'Total Sales',
                                '\$${summary['totalSales'].toStringAsFixed(2)}',
                                Icons.attach_money,
                                AppTheme.gold,
                              ),
                              _buildSummaryCard(
                                'Queued Sales',
                                '${summary['queuedCount']} (\$${summary['queuedTotal'].toStringAsFixed(2)})',
                                Icons.queue,
                                AppTheme.gold,
                              ),
                              _buildSummaryCard(
                                'Synced Sales (24h)',
                                '${summary['syncedCount']} (\$${summary['syncedTotal'].toStringAsFixed(2)})',
                                Icons.cloud_done,
                                AppTheme.gold,
                              ),
                              _buildSummaryCard(
                                'Sync Status',
                                summary['queuedCount'] == 0 ? 'Up to date' : '${summary['queuedCount']} pending',
                                summary['queuedCount'] == 0 ? Icons.check_circle : Icons.sync_problem,
                                AppTheme.gold,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Sales breakdown
                        const Text(
                          'Sales Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Expanded(
                          child: Card(
                            elevation: 8,
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
                                  if (summary['queuedCount'] > 0) ...[
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.gold.withValues(alpha: 0.3),
                                        child: const Icon(Icons.queue, color: AppTheme.gold),
                                      ),
                                      title: const Text('Queued Sales', style: TextStyle(color: Colors.white)),
                                      subtitle: Text(
                                        '${summary['queuedCount']} transactions waiting to sync',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                                      ),
                                      trailing: Text(
                                        '\$${summary['queuedTotal'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.gold,
                                        ),
                                      ),
                                    ),
                                    Divider(color: AppTheme.gold.withValues(alpha: 0.3)),
                                  ],
                                  
                                  if (summary['syncedCount'] > 0) ...[
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.gold.withValues(alpha: 0.3),
                                        child: const Icon(Icons.cloud_done, color: AppTheme.gold),
                                      ),
                                      title: const Text('Synced Sales (Last 24h)', style: TextStyle(color: Colors.white)),
                                      subtitle: Text(
                                        '${summary['syncedCount']} transactions successfully synced',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                                      ),
                                      trailing: Text(
                                        '\$${summary['syncedTotal'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.gold,
                                        ),
                                      ),
                                    ),
                                    Divider(color: AppTheme.gold.withValues(alpha: 0.3)),
                                  ],
                                  
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.gold.withValues(alpha: 0.3),
                                      child: const Icon(Icons.attach_money, color: AppTheme.gold),
                                    ),
                                    title: const Text('Total Sales Value', style: TextStyle(color: Colors.white)),
                                    subtitle: const Text(
                                      'Combined queued and synced sales',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    trailing: Text(
                                      '\$${summary['totalSales'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppTheme.gold,
                                      ),
                                    ),
                                  ),
                                  
                                  if (summary['queuedCount'] == 0 && summary['syncedCount'] == 0)
                                    const Expanded(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.trending_up,
                                              size: 48,
                                              color: AppTheme.gold,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'No sales data yet',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Start adding sales to see reports here',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}