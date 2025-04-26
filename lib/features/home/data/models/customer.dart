import 'package:al_safwa/features/home/data/models/sale_transaction.dart';

class Customer {
  final int? id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? imageUrl;
  List<SaleTransaction> transactions;
  final String? lastPaymentDate;
  final double? lastPaymentAmount;

  Customer({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.address,
    this.email,
    this.imageUrl,
    this.transactions = const [],
    this.lastPaymentDate,
    this.lastPaymentAmount,
  });

  double get balance {
    if (transactions.isEmpty) return 0.0;
      double balance = 0.0;
    for (var transaction in transactions) {
      if (transaction.paymentMethod == 'أجل') {
        balance += transaction.totalAmount - (transaction.paidAmount ?? 0);
      }
    }
    return balance;
  }

  Customer copyWith({
    List<SaleTransaction>? transactions,
    String? lastPaymentDate,
    double? lastPaymentAmount,
  }) {
    return Customer(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      email: email,
      imageUrl: imageUrl,
      transactions: transactions ?? this.transactions,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'email': email,
      'imageUrl': imageUrl,
      'lastPaymentDate': lastPaymentDate,
      'lastPaymentAmount': lastPaymentAmount,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      email: map['email'],
      imageUrl: map['imageUrl'],
      lastPaymentDate: map['lastPaymentDate'],
      lastPaymentAmount: map['lastPaymentAmount'],
    );
  }
}
