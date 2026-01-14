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
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
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
      appBar: AppBar(
        title: const Text('Sales Reports'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                              Colors.green,
                            ),
                            _buildSummaryCard(
                              'Queued Sales',
                              '${summary['queuedCount']} (\$${summary['queuedTotal'].toStringAsFixed(2)})',
                              Icons.queue,
                              Colors.orange,
                            ),
                            _buildSummaryCard(
                              'Synced Sales (24h)',
                              '${summary['syncedCount']} (\$${summary['syncedTotal'].toStringAsFixed(2)})',
                              Icons.cloud_done,
                              Colors.blue,
                            ),
                            _buildSummaryCard(
                              'Sync Status',
                              summary['queuedCount'] == 0 ? 'Up to date' : '${summary['queuedCount']} pending',
                              summary['queuedCount'] == 0 ? Icons.check_circle : Icons.sync_problem,
                              summary['queuedCount'] == 0 ? Colors.green : Colors.red,
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (summary['queuedCount'] > 0) ...[
                                  ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      child: Icon(Icons.queue, color: Colors.white),
                                    ),
                                    title: const Text('Queued Sales'),
                                    subtitle: Text('${summary['queuedCount']} transactions waiting to sync'),
                                    trailing: Text(
                                      '\$${summary['queuedTotal'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                                
                                if (summary['syncedCount'] > 0) ...[
                                  ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.cloud_done, color: Colors.white),
                                    ),
                                    title: const Text('Synced Sales (Last 24h)'),
                                    subtitle: Text('${summary['syncedCount']} transactions successfully synced'),
                                    trailing: Text(
                                      '\$${summary['syncedTotal'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                                
                                ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.attach_money, color: Colors.white),
                                  ),
                                  title: const Text('Total Sales Value'),
                                  subtitle: const Text('Combined queued and synced sales'),
                                  trailing: Text(
                                    '\$${summary['totalSales'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue,
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
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'No sales data yet',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            'Start adding sales to see reports here',
                                            style: TextStyle(
                                              color: Colors.grey,
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
    );
  }
}