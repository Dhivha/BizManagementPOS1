import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'view_sales_screen.dart';
import 'view_bulk_sales_screen.dart';
import 'add_new_sale_screen.dart';
import 'add_bulk_sale_screen.dart';

class SalesMainScreen extends StatefulWidget {
  const SalesMainScreen({super.key});

  @override
  State<SalesMainScreen> createState() => _SalesMainScreenState();
}

class _SalesMainScreenState extends State<SalesMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        backgroundColor: AppTheme.gold,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Regular'),
            Tab(text: 'Bulk Sale'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RegularSalesTab(),
          BulkSalesTab(),
        ],
      ),
    );
  }
}

class RegularSalesTab extends StatelessWidget {
  const RegularSalesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ViewSalesScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewSaleScreen()),
          );
        },
        backgroundColor: AppTheme.gold,
        icon: const Icon(Icons.add),
        label: const Text('Add Sale'),
      ),
    );
  }
}

class BulkSalesTab extends StatelessWidget {
  const BulkSalesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ViewBulkSalesScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBulkSaleScreen()),
          );
        },
        backgroundColor: AppTheme.gold,
        icon: const Icon(Icons.add),
        label: const Text('Add Bulk Sale'),
      ),
    );
  }
}
