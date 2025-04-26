class SaleTransaction {
  final int? id;
  final String? productName;
  final int? quantity;
  final double? unitPrice;
  final double totalAmount;
  final double? paidAmount;
  final String paymentMethod;
  final bool isPayment;
  final DateTime date;
  final double balanceBeforeTransaction;
  final double balanceAfterTransaction;

  SaleTransaction({
    this.id,
    this.productName,
    this.quantity,
    this.unitPrice,
    required this.totalAmount,
    this.paidAmount,
    required this.paymentMethod,
    required this.isPayment,
    required this.date,
    required this.balanceBeforeTransaction,
    required this.balanceAfterTransaction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
      'isPayment': isPayment ? 1 : 0,
      'date': date.toIso8601String(),
      'balanceBeforeTransaction': balanceBeforeTransaction,
      'balanceAfterTransaction': balanceAfterTransaction,
    };
  }

  factory SaleTransaction.fromMap(Map<String, dynamic> map) {
    return SaleTransaction(
      id: map['id'],
      productName: map['productName'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
      totalAmount: map['totalAmount'],
      paidAmount: map['paidAmount'],
      paymentMethod: map['paymentMethod'],
      isPayment: map['isPayment'] == 1,
      date: DateTime.parse(map['date']),
      balanceBeforeTransaction: map['balanceBeforeTransaction'],
      balanceAfterTransaction: map['balanceAfterTransaction'],
    );
  }

  SaleTransaction copyWith({
    double? paidAmount,
    DateTime? lastPaymentDate,
    double? balanceAfterTransaction,
  }) {
    return SaleTransaction(
      id: id,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod,
      isPayment: isPayment,
      date: lastPaymentDate ?? date,
      balanceBeforeTransaction: balanceBeforeTransaction,
      balanceAfterTransaction: balanceAfterTransaction ?? this.balanceAfterTransaction,
    );
  }
}
