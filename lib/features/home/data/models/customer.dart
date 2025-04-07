import 'package:al_safwa/features/home/data/models/sale_transaction%20.dart';

class Customer {
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? imageUrl;
  final List<SaleTransaction> transactions;
  final String? lastPaymentDate;
  final double? lastPaymentAmount;
  

  Customer({
    required this.name,
    required this.phoneNumber,
    this.address,
    this.email,
    this.imageUrl,
    this.transactions = const [],
    this.lastPaymentDate,
    this.lastPaymentAmount,
  });
  

  @override
  bool operator ==(Object other) {
    return other is Customer && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  // إضافة معاملة جديدة
  Customer addTransaction(SaleTransaction newTransaction) {
    return Customer(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      transactions: [...transactions, newTransaction] ?? [],
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
    );
  }


  // حساب الرصيد المتبقي على العميل
  double get balance {
    double totalDebt = transactions.fold(0, (sum, t) => sum + t.totalAmount);
    double totalPaid = transactions.fold(
      0,
      (sum, t) => sum + (t.paidAmount ?? 0),
    );
    return totalDebt - totalPaid; // المبلغ المتبقي
  }

  // تحويل البيانات إلى Map (للتخزين في قاعدة البيانات)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'email': email,
      'imageUrl': imageUrl,
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'lastPaymentDate': lastPaymentDate,
      'lastPaymentAmount': lastPaymentAmount,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      email: map['email'],
      imageUrl: map['imageUrl'],
      transactions: List<SaleTransaction>.from(
        map['transactions']?.map((x) => SaleTransaction.fromMap(x)) ?? [],

      ),
      lastPaymentDate: map['lastPaymentDate'],
      lastPaymentAmount: map['lastPaymentAmount'],
    );
  }

  get phone => null;

Customer  copyWith({
    required List<SaleTransaction> transactions,
    required double balance,
     String? lastPaymentDate, required double lastPaymentAmount,
  }) {
    return Customer(
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      email: email,
      imageUrl: imageUrl,
      transactions: transactions,
      lastPaymentDate:  lastPaymentDate,
      lastPaymentAmount: lastPaymentAmount,
    );
  }
  
}
