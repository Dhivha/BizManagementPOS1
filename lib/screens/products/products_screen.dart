import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../utils/app_theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initializeProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductProvider>().refreshProducts();
            },
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: AppTheme.cardLight,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon:
                            const Icon(Icons.search, color: AppTheme.gold),
                        suffixIcon: productProvider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppTheme.gold),
                                onPressed: () {
                                  _searchController.clear();
                                  productProvider.clearSearch();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppTheme.primaryNavy,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: AppTheme.gold),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: AppTheme.gold, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        productProvider.searchProducts(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Filter
                    if (productProvider.categories.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.filter_list,
                              color: AppTheme.gold, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Category:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildCategoryChip('All', productProvider),
                                  ...productProvider.categories.map(
                                    (category) => _buildCategoryChip(
                                        category, productProvider),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Results Counter
                    if (!productProvider.isLoading) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppTheme.gold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${productProvider.products.length} products found',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: _buildContent(productProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category, ProductProvider productProvider) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryNavy : Colors.white,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
          productProvider.filterByCategory(category);
        },
        backgroundColor: AppTheme.primaryNavy,
        selectedColor: AppTheme.gold,
        checkmarkColor: AppTheme.primaryNavy,
        side: BorderSide(
          color: isSelected ? AppTheme.gold : Colors.white30,
        ),
      ),
    );
  }

  Widget _buildContent(ProductProvider productProvider) {
    if (productProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.gold),
            SizedBox(height: 16),
            Text(
              'Loading products...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (productProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${productProvider.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                productProvider.refreshProducts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.primaryNavy,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (productProvider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white30,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              productProvider.searchQuery.isNotEmpty
                  ? 'No products found for "${productProvider.searchQuery}"'
                  : 'No products available',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            if (productProvider.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  productProvider.clearSearch();
                },
                child: const Text(
                  'Clear search',
                  style: TextStyle(color: AppTheme.gold),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: productProvider.products.length,
      itemBuilder: (context, index) {
        final product = productProvider.products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory,
                    color: AppTheme.gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Product ID
            Row(
              children: [
                const Icon(Icons.tag, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                Text(
                  'ID: ${product.productId}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDescriptionDialog(product),
                    icon: const Icon(Icons.description, size: 16),
                    label: const Text('View Description'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.gold,
                      side: const BorderSide(color: AppTheme.gold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showProductDetails(product),
                  icon: const Icon(Icons.info_outline, color: AppTheme.gold),
                  tooltip: 'Product Details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDescriptionDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardLight,
        title: Text(
          product.productName,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            product.description,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  product.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Details
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildDetailRow(
                          'Product ID', product.productId, Icons.tag),
                      _buildDetailRow(
                          'Category', product.category, Icons.category),
                      _buildDetailRow(
                          'Price', product.formattedPrice, Icons.attach_money),
                      _buildDetailRow(
                          'Created',
                          '${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}',
                          Icons.calendar_today),
                      if (product.updatedAt != null)
                        _buildDetailRow(
                            'Updated',
                            '${product.updatedAt!.day}/${product.updatedAt!.month}/${product.updatedAt!.year}',
                            Icons.update),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          product.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
