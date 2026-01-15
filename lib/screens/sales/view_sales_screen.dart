import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale.dart';
import '../../providers/sales_provider.dart';
import '../../utils/app_theme.dart';

class ViewSalesScreen extends StatefulWidget {
  const ViewSalesScreen({super.key});

  @override
  State<ViewSalesScreen> createState() => _ViewSalesScreenState();
}

class _ViewSalesScreenState extends State<ViewSalesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSales();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
    });

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    await salesProvider.loadSales();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _syncQueuedSales() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    
    if (salesProvider.queuedSales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No queued sales to sync')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await salesProvider.syncAllQueuedSales();

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync attempt completed. Check results in tabs.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Widget _buildSaleCard(Sale sale, {bool isQueued = true}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isQueued ? Colors.orange : Colors.green,
          child: Icon(
            isQueued ? Icons.queue : Icons.sync,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Sale ${sale.id.substring(sale.id.length - 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: \$${sale.totalAmount.toStringAsFixed(2)} ${sale.currency}'),
            Text('Date: ${sale.dateOfSale.toLocal().toString().split('.')[0]}'),
            if (sale.notes?.isNotEmpty == true) Text('Notes: ${sale.notes}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item.productName} (${item.quantityInUnits})'),
                      ),
                      Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${sale.totalAmount.toStringAsFixed(2)} ${sale.currency}', 
                         style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuedSalesTab() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        final queuedSales = salesProvider.queuedSales;
        
        if (queuedSales.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No queued sales', style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text('All sales have been synced successfully!'),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${queuedSales.length} sales pending sync to server',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSales,
                child: ListView.builder(
                  itemCount: queuedSales.length,
                  itemBuilder: (context, index) {
                    return _buildSaleCard(queuedSales[index], isQueued: true);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSyncedSalesTab() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        final syncedSales = salesProvider.syncedSales;
        
        if (syncedSales.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No recent synced sales', style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text('Synced sales are kept for 24 hours'),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${syncedSales.length} sales synced in last 24 hours',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSales,
                child: ListView.builder(
                  itemCount: syncedSales.length,
                  itemBuilder: (context, index) {
                    return _buildSaleCard(syncedSales[index], isQueued: false);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Sales'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<SalesProvider>(
            builder: (context, salesProvider, child) {
              if (salesProvider.queuedSales.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: _isLoading ? null : _syncQueuedSales,
                  tooltip: 'Sync Queued Sales',
                );
              }
              return const SizedBox();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Consumer<SalesProvider>(
              builder: (context, salesProvider, child) {
                return Tab(
                  text: 'Queued (${salesProvider.queuedSales.length})',
                );
              },
            ),
            Consumer<SalesProvider>(
              builder: (context, salesProvider, child) {
                return Tab(
                  text: 'Synced (${salesProvider.syncedSales.length})',
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQueuedSalesTab(),
                _buildSyncedSalesTab(),
              ],
            ),
    );
  }
}