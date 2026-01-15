import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/bulk_sales_provider.dart';
import 'providers/purchases_provider.dart';
import 'providers/other_income_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/settings/bluetooth_printer_screen.dart';
import 'utils/app_theme.dart';
import 'utils/provider_initialization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BizManagementApp());
}

class BizManagementApp extends StatelessWidget {
  const BizManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => BulkSalesProvider()),
        ChangeNotifierProvider(create: (_) => PurchasesProvider()),
        ChangeNotifierProvider(create: (_) => OtherIncomeProvider()),
      ],
      builder: (context, child) {
        // Initialize provider dependencies after all providers are created
        final authProvider = context.read<AuthProvider>();
        final salesProvider = context.read<SalesProvider>();
        final purchasesProvider = context.read<PurchasesProvider>();
        final otherIncomeProvider = context.read<OtherIncomeProvider>();
        
        initializeProviderDependencies(authProvider, salesProvider, purchasesProvider, otherIncomeProvider);
        
        return MaterialApp(
          title: 'BizManagement',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/printer-settings': (context) => const BluetoothPrinterScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize authentication on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}