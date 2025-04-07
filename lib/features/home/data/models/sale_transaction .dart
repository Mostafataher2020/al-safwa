class SaleTransaction {
  final DateTime date;
  final String? productName;
  final int? quantity;
  final double? unitPrice;
  final String paymentMethod;
  final double paidAmount;
  final bool isPayment;
  final double balanceAfterTransaction; // <-- إض
final DateTime? lastPaymentDate;  

  SaleTransaction({
    required this.date,
    this.productName,
    this.quantity,
    this.unitPrice,
    required this.paymentMethod,
    this.paidAmount = 0,
    this.isPayment = false,
    required this.balanceAfterTransaction, // <-- إضافة هذا الحقل
    this.lastPaymentDate, // <-- إضافة هذا الحقل
  });

  double get totalAmount => isPayment ? paidAmount : (quantity! * unitPrice!);

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'paymentMethod': paymentMethod,
      'paidAmount': paidAmount,
      'isPayment': isPayment,
      'balanceAfterTransaction': balanceAfterTransaction, // <-- إضافة هذا الحقل
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
    };
  }

  factory SaleTransaction.fromMap(Map<String, dynamic> map) {
    return SaleTransaction(
      date: DateTime.parse(map['date']),
      productName: map['productName'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
      paymentMethod: map['paymentMethod'],
      paidAmount: map['paidAmount'] ?? 0,
      isPayment: map['isPayment'] ?? false,
      balanceAfterTransaction: map['balanceAfterTransaction'] ?? 0, // <-- إضافة هذا الحقل
      lastPaymentDate: map['lastPaymentDate'] != null ? DateTime.parse(map['lastPaymentDate']) : null,
    );
  }

  SaleTransaction copyWith({required double paidAmount,  DateTime? lastPaymentDate,  double? balanceAfterTransaction,DateTime }) {
    return SaleTransaction(
      date: date ?? this.date,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      isPayment: isPayment ?? this.isPayment,
      balanceAfterTransaction: balanceAfterTransaction ?? this.balanceAfterTransaction, // <-- إضافة هذا الحقل
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate, // <-- إضافة هذا الحقل
    );
  }
}