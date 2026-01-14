class ApiConfig {
  // Your API base URL - configured once here for the entire app
  static const String baseUrl = 'https://ndvf9jzb-7124.uks1.devtunnels.ms';
  
  // API endpoints
  static const String apiVersion = '/api';
  static const String fullApiUrl = '$baseUrl$apiVersion';
  
  // Common endpoints
  static const String login = '$fullApiUrl/Auth/login';
  static const String register = '$fullApiUrl/Auth/register';
  static const String profile = '$fullApiUrl/User/profile';
  static const String dashboard = '$fullApiUrl/Dashboard';
  
  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}

class ApiEndpoints {
  // Authentication endpoints
  static const String login = '/Auth/login';
  static const String logout = '/Auth/logout';
  static const String register = '/Auth/register';
  static const String refreshToken = '/Auth/refresh';
  
  // User endpoints
  static const String userProfile = '/User/profile';
  static const String updateProfile = '/User/profile';
  
  // Business endpoints
  static const String businesses = '/Business';
  static const String createBusiness = '/Business';
  static String businessDetails(int id) => '/Business/$id';
  
  // Dashboard endpoints
  static const String dashboardData = '/Dashboard';
  static const String analytics = '/Dashboard/analytics';
  
  // Butchery Product Management endpoints
  static const String loadProducts = '/butchery/ProductManagement/load-products';
  static const String createProduct = '/butchery/ProductManagement/create-product';
  static String updateProduct(int id) => '/butchery/ProductManagement/update-product/$id';
  static String updateProductByProductId(String productId) => '/butchery/ProductManagement/update-product-by-productid/$productId';
  static String getPricePerUnit(String productId) => '/butchery/ProductManagement/get-price-per-unit/$productId';
  static String updatePricePerUnit(String productId) => '/butchery/ProductManagement/update-price-per-unit/$productId';
  static String deleteProduct(int id) => '/butchery/ProductManagement/delete-product/$id';
}