import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/purchase.dart';
import '../../providers/purchases_provider.dart';
import '../../utils/app_theme.dart';
import 'add_purchase_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchases();
    });
  }

  Future<void> _loadPurchases() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final purchasesProvider = Provider.of<PurchasesProvider>(context, listen: false);
    await purchasesProvider.loadPurchases();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPurchaseCard(Purchase purchase) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.gold,
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Purchase #${purchase.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoice Amount: \$${purchase.purchasesInvoiceAmount.toStringAsFixed(2)} ${purchase.currency}'),
            Text('Amount Paid: \$${purchase.amountPaid.toStringAsFixed(2)}'),
            Text('Amount Owing: \$${purchase.amountOwing.toStringAsFixed(2)}'),
            Text('Date: ${purchase.dateOfPurchases.toLocal().toString().split('.')[0]}'),
            if (purchase.notes?.isNotEmpty == true) Text('Notes: ${purchase.notes}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Department:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(purchase.department),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expenses:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${purchase.purchasesExpenses.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...purchase.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.productName} (${item.productId})',
                           style: const TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('  Qty: ${item.quantityInUnits} x \$${item.unitCost.toStringAsFixed(2)}'),
                          Text('\$${item.totalAmount.toStringAsFixed(2)}', 
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                )),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Invoice Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('\$${purchase.purchasesInvoiceAmount.toStringAsFixed(2)} ${purchase.currency}', 
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount Paid:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${purchase.amountPaid.toStringAsFixed(2)}', 
                         style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount Owing:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${purchase.amountOwing.toStringAsFixed(2)}', 
                         style: TextStyle(color: purchase.amountOwing > 0 ? Colors.red[700] : Colors.grey, 
                                          fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        backgroundColor: AppTheme.gold,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<PurchasesProvider>(
              builder: (context, purchasesProvider, child) {
                if (purchasesProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${purchasesProvider.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPurchases,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final purchases = purchasesProvider.purchases;

                if (purchases.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No purchases yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Tap the + button to add a new purchase'),
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
                          const Text('Total Purchases:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('\$${purchasesProvider.totalPurchasesInvoiceAmount.toStringAsFixed(2)}', 
                               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.gold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadPurchases,
                        child: ListView.builder(
                          itemCount: purchases.length,
                          itemBuilder: (context, index) {
                            return _buildPurchaseCard(purchases[index]);
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
            MaterialPageRoute(builder: (context) => const AddPurchaseScreen()),
          ).then((_) => _loadPurchases());
        },
        backgroundColor: AppTheme.gold,
        icon: const Icon(Icons.add),
        label: const Text('Capture New Purchase'),
      ),
    );
  }
}
