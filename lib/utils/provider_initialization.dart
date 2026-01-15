
import '../providers/auth_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/purchases_provider.dart';
import '../providers/other_income_provider.dart';

/// Initialize provider dependencies and callbacks
void initializeProviderDependencies(
  AuthProvider authProvider,
  SalesProvider salesProvider,
  PurchasesProvider purchasesProvider,
  OtherIncomeProvider otherIncomeProvider,
) {
  // Set up callback so SalesProvider knows when user changes
  authProvider.setOnUserChanged((user) {
    salesProvider.setCurrentUser(user);
  });
  
  // Set current user if already logged in
  if (authProvider.user != null) {
    salesProvider.setCurrentUser(authProvider.user);
  }
}