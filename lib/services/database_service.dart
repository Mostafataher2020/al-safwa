import 'package:al_safwa/features/admin/data/models/business_owner.dart';
import 'package:al_safwa/features/home/data/models/customer.dart';
import 'package:al_safwa/features/home/data/models/sale_transaction.dart';  // Fix import
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('al_safwa.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE business_owner (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        factory TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        address TEXT,
        imageUrl TEXT,
        lastPaymentDate TEXT,
        lastPaymentAmount REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        productName TEXT,
        quantity INTEGER,
        unitPrice REAL,
        totalAmount REAL NOT NULL,
        paidAmount REAL,
        balanceBeforeTransaction REAL NOT NULL,
        balanceAfterTransaction REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        isPayment INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<BusinessOwner?> getBusinessOwner() async {
    final db = await instance.database;
    final result = await db.query('business_owner', limit: 1);
    if (result.isNotEmpty) {
      return BusinessOwner.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertOrUpdateBusinessOwner(BusinessOwner owner) async {
    final db = await instance.database;
    await db.insert(
      'business_owner',
      owner.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await instance.database;
    final result = await db.query('customers');
    List<Customer> customers = result.map((map) => Customer.fromMap(map)).toList();

    for (var customer in customers) {
      if (customer.id != null) {
        customer.transactions = await getTransactionsForCustomer(customer.id!);
      } else {
        customer.transactions = [];
      }
    }

    return customers;
  }

  Future<void> insertOrUpdateCustomer(Customer customer) async {
    final db = await instance.database;
    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCustomer(int id) async {
    final db = await instance.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SaleTransaction>> getTransactionsForCustomer(int customerId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return result.map((map) {
      // Ensure all fields are properly mapped
      final adjustedMap = Map<String, dynamic>.from(map);
      return SaleTransaction.fromMap(adjustedMap);
    }).toList();
  }

  Future<int> addTransaction(int customerId, SaleTransaction transaction) async {
    final db = await database;
    final map = transaction.toMap();
    map['customerId'] = customerId;
    final id = await db.insert('transactions', map);
    return id;
  }

  Future<bool> updateTransaction(int transactionId, SaleTransaction transaction) async {
    final db = await database;
    final map = transaction.toMap();
    map.remove('id'); // Remove id from update
    final count = await db.update(
      'transactions',
      map,
      where: 'id = ?',
      whereArgs: [transactionId],
    );
    return count > 0;
  }

  Future<bool> deleteTransaction(int transactionId) async {
    final db = await database;
    final count = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );
    return count > 0; // Return true if the delete was successful
  }

  Future<void> deleteTransactionsForCustomer(int customerId) async {
    final db = await instance.database;
    await db.delete('transactions', where: 'customerId = ?', whereArgs: [customerId]);
  }
}
