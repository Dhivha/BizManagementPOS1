import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../products/products_screen.dart';
import '../sales/sales_dashboard_screen.dart';
import '../expenses/expenses_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeWidget(),
    const BusinessListWidget(),
    const AnalyticsWidget(),
    const ProfileWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BizManagement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notifications feature coming soon!')),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.pushNamed(context, '/printer-settings');
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}

// Dashboard Home Widget
class DashboardHomeWidget extends StatefulWidget {
  const DashboardHomeWidget({super.key});

  @override
  State<DashboardHomeWidget> createState() => _DashboardHomeWidgetState();
}

class _DashboardHomeWidgetState extends State<DashboardHomeWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize products when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initializeProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          authProvider.user?.fullName
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${authProvider.user?.fullName ?? 'User'}!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.user?.username ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
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
          const SizedBox(height: 24),

          // Quick Stats
          const Text(
            'Quick Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Sales',
                  '\$0',
                  Icons.point_of_sale,
                  Colors.green,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SalesDashboardScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Purchases',
                  '\$0',
                  Icons.shopping_cart,
                  Colors.blue,
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
                  '\$0',
                  Icons.money_off,
                  Colors.red,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ExpensesDashboard(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Other Incomes',
                  '\$0',
                  Icons.attach_money,
                  Colors.orange,
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
                child: Container(), // Empty space for symmetry
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.add_business),
                  title: const Text('Add New Business'),
                  subtitle: const Text('Register a new business'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Add Business feature coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.assessment),
                  title: const Text('View Analytics'),
                  subtitle: const Text('Check your business performance'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Analytics feature coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Receipt Printer'),
                  subtitle: const Text('Configure auto-receipt printing'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(context, '/printer-settings');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  subtitle: const Text('Manage your preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(context, '/printer-settings');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Business List Widget
class BusinessListWidget extends StatelessWidget {
  const BusinessListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No businesses yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Add your first business to get started'),
        ],
      ),
    );
  }
}

// Analytics Widget
class AnalyticsWidget extends StatelessWidget {
  const AnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Analytics Coming Soon',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Business analytics will be available here'),
        ],
      ),
    );
  }
}

// Profile Widget
class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.username ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Profile Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(Icons.person, 'Full Name',
                          user?.fullName ?? 'Not provided'),
                      const SizedBox(height: 12),
                      _buildProfileDetailRow(Icons.account_circle, 'Username',
                          user?.username ?? 'Not provided'),
                      const SizedBox(height: 12),
                      _buildProfileDetailRow(
                          Icons.phone, 'Phone', user?.phone ?? 'Not provided'),
                      if (user?.phone2 != null && user!.phone2!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildProfileDetailRow(
                            Icons.phone_android, 'Phone 2', user.phone2!),
                      ],
                      const SizedBox(height: 12),
                      _buildProfileDetailRow(Icons.badge, 'ID Number',
                          user?.idNumber ?? 'Not provided'),
                      const SizedBox(height: 12),
                      _buildProfileDetailRow(
                          Icons.cake,
                          'Date of Birth',
                          user?.dateOfBirth != null
                              ? '${user!.dateOfBirth.day}/${user.dateOfBirth.month}/${user.dateOfBirth.year}'
                              : 'Not provided'),
                      const SizedBox(height: 16),
                      const Text(
                        'Work Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(Icons.business, 'Department',
                          user?.department ?? 'Not provided'),
                      const SizedBox(height: 12),
                      _buildProfileDetailRow(Icons.work, 'Position',
                          _getPositionName(user?.position)),
                      const SizedBox(height: 12),
                      _buildProfileDetailRow(
                        user?.isActive == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        'Status',
                        user?.isActive == true ? 'Active' : 'Inactive',
                        color:
                            user?.isActive == true ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildProfileDetailRow(
                          Icons.calendar_today,
                          'Member Since',
                          user?.createdAt != null
                              ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                              : 'Not available'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Profile Options
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Edit Profile feature coming soon!')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Privacy & Security'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Privacy Settings feature coming soon!')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Help & Support feature coming soon!')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('About BizManagement'),
                            content: const Text(
                                'Version 1.0.0\nA professional business management application.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value,
      {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getPositionName(int? position) {
    switch (position) {
      case 0:
        return 'Administrator';
      case 1:
        return 'Manager';
      case 2:
        return 'Employee';
      case 3:
        return 'Supervisor';
      default:
        return 'Not specified';
    }
  }
}
