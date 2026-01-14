import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/sale.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'biz_management_v4.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // User table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        idNumber TEXT NOT NULL,
        phone TEXT NOT NULL,
        phone2 TEXT,
        department TEXT NOT NULL,
        position INTEGER NOT NULL,
        username TEXT NOT NULL UNIQUE,
        isActive INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Auth tokens table
    await db.execute('''
      CREATE TABLE auth_tokens(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        userId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        productId TEXT NOT NULL UNIQUE,
        productName TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        pricePerUnit REAL NOT NULL,
        currentInStockInUnit INTEGER NOT NULL DEFAULT 0,
        unit TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Queued sales table
    await db.execute('''
      CREATE TABLE queued_sales(
        id TEXT PRIMARY KEY,
        dateOfSale TEXT NOT NULL,
        currency TEXT NOT NULL,
        department TEXT NOT NULL,
        notes TEXT,
        totalAmount REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Synced sales table
    await db.execute('''
      CREATE TABLE synced_sales(
        id TEXT PRIMARY KEY,
        dateOfSale TEXT NOT NULL,
        currency TEXT NOT NULL,
        department TEXT NOT NULL,
        notes TEXT,
        totalAmount REAL NOT NULL,
        syncedAt TEXT NOT NULL
      )
    ''');

    // Sale items table (for both queued and synced sales)
    await db.execute('''
      CREATE TABLE sale_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        quantityInUnits REAL NOT NULL,
        pricePerUnit REAL NOT NULL,
        totalPrice REAL NOT NULL,
        isQueued INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add products table
      await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY,
          productId TEXT NOT NULL,
          productName TEXT NOT NULL,
          category TEXT NOT NULL,
          description TEXT NOT NULL,
          pricePerUnit REAL NOT NULL,
          currentInStockInUnit INTEGER NOT NULL,
          unit TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          isActive INTEGER NOT NULL DEFAULT 1
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Add sales tables
      await db.execute('''
        CREATE TABLE queued_sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          saleId TEXT NOT NULL UNIQUE,
          totalAmount REAL NOT NULL,
          currency TEXT NOT NULL DEFAULT 'UGX',
          saleDate TEXT NOT NULL,
          soldBy TEXT NOT NULL,
          soldTo TEXT,
          isQueued INTEGER NOT NULL DEFAULT 1,
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE synced_sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          saleId TEXT NOT NULL UNIQUE,
          totalAmount REAL NOT NULL,
          currency TEXT NOT NULL DEFAULT 'UGX',
          saleDate TEXT NOT NULL,
          soldBy TEXT NOT NULL,
          soldTo TEXT,
          apiSaleId TEXT,
          syncedAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE sale_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          saleId TEXT NOT NULL,
          productId TEXT NOT NULL,
          productName TEXT NOT NULL,
          quantityInUnits REAL NOT NULL,
          pricePerUnit REAL NOT NULL,
          totalPrice REAL NOT NULL,
          isQueued INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (saleId) REFERENCES queued_sales (saleId)
        )
      ''');
    }
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      {
        'id': user.id,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'dateOfBirth': user.dateOfBirth.toIso8601String(),
        'idNumber': user.idNumber,
        'phone': user.phone,
        'phone2': user.phone2,
        'department': user.department,
        'position': user.position,
        'username': user.username,
        'isActive': user.isActive ? 1 : 0,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User(
        id: map['id'] as int,
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
        idNumber: map['idNumber'] as String,
        phone: map['phone'] as String,
        phone2: map['phone2'] as String?,
        department: map['department'] as String,
        position: map['position'] as int,
        username: map['username'] as String,
        isActive: (map['isActive'] as int) == 1,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null 
            ? DateTime.parse(map['updatedAt'] as String) 
            : null,
      );
    }
    return null;
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User(
        id: map['id'] as int,
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
        idNumber: map['idNumber'] as String,
        phone: map['phone'] as String,
        phone2: map['phone2'] as String?,
        department: map['department'] as String,
        position: map['position'] as int,
        username: map['username'] as String,
        isActive: (map['isActive'] as int) == 1,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null 
            ? DateTime.parse(map['updatedAt'] as String) 
            : null,
      );
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      {
        'firstName': user.firstName,
        'lastName': user.lastName,
        'dateOfBirth': user.dateOfBirth.toIso8601String(),
        'idNumber': user.idNumber,
        'phone': user.phone,
        'phone2': user.phone2,
        'department': user.department,
        'position': user.position,
        'username': user.username,
        'isActive': user.isActive ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Auth token operations
  Future<void> saveAuthToken(String token, int userId) async {
    final db = await database;
    // Clear existing tokens first
    await db.delete('auth_tokens');
    
    // Insert new token
    await db.insert(
      'auth_tokens',
      {
        'token': token,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<String?> getAuthToken() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'auth_tokens',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['token'] as String;
    }
    return null;
  }

  Future<void> clearAuthToken() async {
    final db = await database;
    await db.delete('auth_tokens');
  }

  // Product operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();
    
    for (final product in products) {
      batch.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    final results = await batch.commit();
    return results.length;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'productName ASC',
    );

    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<Product?> getProductByProductId(String productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'productId = ?',
      whereArgs: [productId],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: '''
        productId LIKE ? OR 
        productName LIKE ? OR 
        category LIKE ? OR 
        description LIKE ? OR 
        CAST(pricePerUnit AS TEXT) LIKE ?
      ''',
      whereArgs: List.filled(5, '%$query%'),
      orderBy: 'productName ASC',
    );

    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllProducts() async {
    final db = await database;
    await db.delete('products');
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('auth_tokens');
    await db.delete('products');
    await db.delete('queued_sales');
    await db.delete('synced_sales');
    await db.delete('sale_items');
  }

  // Sales operations
  Future<int> insertQueuedSale(Sale sale) async {
    try {
      debugPrint('DatabaseHelper: Starting insertQueuedSale for sale ${sale.id}');
      final db = await database;
      debugPrint('DatabaseHelper: Database connection obtained');
      
      // Start a transaction
      await db.transaction((txn) async {
        debugPrint('DatabaseHelper: Transaction started');
        
        // Insert the sale
        final saleMap = sale.toMap();
        debugPrint('DatabaseHelper: Sale data to insert: $saleMap');
        
        await txn.insert('queued_sales', saleMap);
        debugPrint('DatabaseHelper: ✅ Sale inserted into queued_sales table');
        
        // Insert all sale items
        debugPrint('DatabaseHelper: Inserting ${sale.items.length} sale items...');
        for (var i = 0; i < sale.items.length; i++) {
          var item = sale.items[i];
          final itemMap = {
            ...item.toMap(),
            'saleId': sale.id,
            'isQueued': 1,
          };
          debugPrint('DatabaseHelper: Item $i data: $itemMap');
          
          await txn.insert('sale_items', itemMap);
          debugPrint('DatabaseHelper: ✅ Item $i inserted successfully');
        }
        
        debugPrint('DatabaseHelper: ✅ Transaction completed successfully');
      });
      
      debugPrint('DatabaseHelper: ✅ insertQueuedSale completed successfully');
      return 1; // Success
    } catch (e, stackTrace) {
      debugPrint('DatabaseHelper: ❌ ERROR in insertQueuedSale: $e');
      debugPrint('DatabaseHelper: ❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Sale>> getQueuedSales() async {
    final db = await database;
    
    // Get all queued sales
    final salesMaps = await db.query('queued_sales', orderBy: 'createdAt DESC');
    
    List<Sale> sales = [];
    for (var saleMap in salesMaps) {
      // Get items for this sale
      final itemsMaps = await db.query(
        'sale_items',
        where: 'saleId = ? AND isQueued = ?',
        whereArgs: [saleMap['id'], 1],
      );
      
      final items = itemsMaps.map((map) => SaleItem.fromMap(map)).toList();
      
      final sale = Sale.fromMap(saleMap);
      sale.items.clear();
      sale.items.addAll(items);
      
      sales.add(sale);
    }
    
    return sales;
  }

  Future<List<Sale>> getSyncedSales() async {
    final db = await database;
    
    // Get synced sales from the last 24 hours
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
    
    final salesMaps = await db.query(
      'synced_sales',
      where: 'syncedAt >= ?',
      whereArgs: [twentyFourHoursAgo.toIso8601String()],
      orderBy: 'syncedAt DESC',
    );
    
    List<Sale> sales = [];
    for (var saleMap in salesMaps) {
      // Get items for this sale
      final itemsMaps = await db.query(
        'sale_items',
        where: 'saleId = ? AND isQueued = ?',
        whereArgs: [saleMap['id'], 0],
      );
      
      final items = itemsMaps.map((map) => SaleItem.fromMap(map)).toList();
      
      final sale = Sale.fromMapSynced(saleMap);
      sale.items.clear();
      sale.items.addAll(items);
      
      sales.add(sale);
    }
    
    return sales;
  }

  Future<void> moveSaleToSynced(String saleId) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Get the queued sale
      final salesMaps = await txn.query(
        'queued_sales',
        where: 'id = ?',
        whereArgs: [saleId],
      );
      
      if (salesMaps.isNotEmpty) {
        final saleMap = salesMaps.first;
        
        // Insert into synced_sales with correct mapping
        await txn.insert('synced_sales', {
          'id': saleMap['id'],  // Use id directly
          'dateOfSale': saleMap['dateOfSale'],
          'currency': saleMap['currency'],
          'department': saleMap['department'],
          'notes': saleMap['notes'],
          'totalAmount': saleMap['totalAmount'],
          'syncedAt': DateTime.now().toIso8601String(),
        });
        
        // Update sale_items to mark as synced
        await txn.update(
          'sale_items',
          {'isQueued': 0},
          where: 'saleId = ?',
          whereArgs: [saleId],
        );
        
        // Remove from queued_sales
        await txn.delete(
          'queued_sales',
          where: 'id = ?',
          whereArgs: [saleId],
        );
      }
    });
  }

  Future<void> cleanupOldSyncedSales() async {
    final db = _database!;
    
    // Delete synced sales older than 24 hours
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
    
    await db.transaction((txn) async {
      // Get sale IDs to delete
      final oldSales = await txn.query(
        'synced_sales',
        columns: ['id'],
        where: 'syncedAt < ?',
        whereArgs: [twentyFourHoursAgo.toIso8601String()],
      );
      
      // Delete sale items for these sales
      for (var sale in oldSales) {
        await txn.delete(
          'sale_items',
          where: 'saleId = ? AND isQueued = ?',
          whereArgs: [sale['id'], 0],
        );
      }
      
      // Delete the old synced sales
      await txn.delete(
        'synced_sales',
        where: 'syncedAt < ?',
        whereArgs: [twentyFourHoursAgo.toIso8601String()],
      );
    });
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}