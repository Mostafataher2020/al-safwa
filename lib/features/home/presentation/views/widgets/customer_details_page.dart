import 'dart:io';
import 'dart:math';

import 'package:al_safwa/features/admin/presentation/manager/admin_cubit/business_cubit.dart';
import 'package:al_safwa/features/home/data/models/sale_transaction%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_safwa/features/home/presentation/manager/customers_cubit/customer_cubit.dart';
import 'package:al_safwa/features/home/data/models/customer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../admin/data/models/business_owner.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({Key? key, required this.customer})
    : super(key: key);

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  late Customer _currentCustomer;
  double _cumulativeBalance = 0.0;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    _cumulativeBalance = _calculateCumulativeBalance();
  }

  double _calculateCumulativeBalance() {
    double balance = 0.0;
    for (var transaction in _currentCustomer.transactions) {
      if (transaction.paymentMethod == 'أجل') {
        balance += transaction.totalAmount - (transaction.paidAmount ?? 0);
      }
    }
    return balance;
  }

  Future<void> _showPaymentDialog() async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسديد دفعة'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ المدفوع',
                        suffixText: 'جنيه',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال المبلغ';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'الرجاء إدخال مبلغ صحيح';
                        }
                        if (amount > _cumulativeBalance) {
                          return 'المبلغ أكبر من الرصيد المستحق';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'الرصيد المستحق: ${_cumulativeBalance.toStringAsFixed(2)} جنيه',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final paidAmount = double.parse(amountController.text);
                    _recordPayment(paidAmount);
                    Navigator.pop(context);
                  }
                },
                child: const Text('تأكيد الدفع'),
              ),
            ],
          ),
    );
  }

  void _recordPayment(double paidAmount) async {
    if (_isProcessingPayment || paidAmount <= 0) return;

    setState(() => _isProcessingPayment = true);

    try {
      List<SaleTransaction> updatedTransactions = [];
      double remainingPayment = paidAmount;
      double newBalance = _cumulativeBalance;

      // 1. تحديث المعاملات
      for (var transaction in _currentCustomer.transactions) {
        if (remainingPayment <= 0) {
          updatedTransactions.add(transaction);
          continue;
        }

        if (transaction.paymentMethod == 'أجل' &&
            (transaction.paidAmount ?? 0) < transaction.totalAmount) {
          double remainingInTransaction =
              transaction.totalAmount - (transaction.paidAmount ?? 0);
          double paymentToApply = min(remainingPayment, remainingInTransaction);

          updatedTransactions.add(
            transaction.copyWith(
              paidAmount: (transaction.paidAmount ?? 0) + paymentToApply,
              lastPaymentDate: DateTime.now(),
              balanceAfterTransaction:
                  (transaction.balanceAfterTransaction ??
                      transaction.totalAmount) -
                  paymentToApply,
            ),
          );

          remainingPayment -= paymentToApply;
          newBalance -= paymentToApply;
        } else {
          updatedTransactions.add(transaction);
        }
      }

      // 2. تسجيل تحذير إذا كان المبلغ غير كافٍ
      if (remainingPayment > 0) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم سداد ${paidAmount - remainingPayment} من $paidAmount فقط',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      
      }

      // 3. تحديث بيانات العميل
      Customer updatedCustomer2 = _currentCustomer.copyWith(
        transactions: updatedTransactions,
        balance: newBalance,
        lastPaymentDate: DateTime.now().toIso8601String(),
        lastPaymentAmount: paidAmount,
      );

      // 4. حفظ التغييرات
      await context.read<CustomerCubit>().updateCustomer2(
        _currentCustomer.name,
        updatedCustomer2,
      );

      // 5. تحديث الواجهة
      if (!mounted) return;

      setState(() {
        _currentCustomer = updatedCustomer2;
        _cumulativeBalance = newBalance;
        _isProcessingPayment = false;
      });

      showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text('تحذير'),
            content:  Text(
              'تم سداد ''${paidAmount - remainingPayment} من $paidAmount فقط',
              textAlign: TextAlign.center,
            ),
            icon: IconButton(onPressed: (){
                shareInvoiceAsPdf(
                  _currentCustomer.name,
                  _currentCustomer.phoneNumber,
                  paidAmount - remainingPayment,
                );
            }, icon: Icon(Icons.share)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          );
        });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في السداد: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => _isProcessingPayment = false);
    }
  }



Future<void> shareAccountDetailsAsPdf(String ownerName,String ownerPhone) async {
  // Load a font that supports Arabic (make sure to include the font file in your assets)
  final arabicFont = pw.Font.ttf(await rootBundle.load("assets/fonts/alfont_com_Tasees-Bold.ttf"));
  // Or use a default font that supports Arabic (like 'Arial Unicode MS' if available)
  
  // Create PDF document
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(
        base: arabicFont, // Use the Arabic-supporting font
      ),
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl, // Right-to-left for Arabic
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
            // Header Row
                  pw.Row(
                  
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'اسم صاحب الشركة',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          ownerName,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                  
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'رقم الهاتف',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          ownerPhone,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                    ],
                  ),  
              // Header
              pw.Center(
                child: pw.Text(
                  'تفاصيل الحساب',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: arabicFont,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Table with borders
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                },
                children: [
                  
                  // Table Header
                  pw.TableRow(
                    children: [  pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'القيمة',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'المعلومات',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),  
                        ),
                      ),
                    
                    ],
                  ),
                  
                  // Customer Data Rows
                  _buildTableRow('الاسم', _currentCustomer.name),
                  _buildTableRow('رقم الهاتف', _currentCustomer.phoneNumber),
                  _buildTableRow('الرصيد', '${_currentCustomer.balance.toStringAsFixed(2)} جنيه'),
                  
                  // Add more rows as needed
                ],
              ),
              
            
            ],
          ),
        );
      },
    ),
  );

  // Save to temporary file and share
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/customer_summary.pdf');
  await file.writeAsBytes(await pdf.save());
  
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'تفاصيل الحساب - ${_currentCustomer.name}',
    subject: 'تفاصيل الحساب',
  );
}
Future<void> shareInvoiceAsPdf(String ownerName,String ownerPhone,double paymentAmount) async {
  // Load a font that supports Arabic (make sure to include the font file in your assets)
  final arabicFont = pw.Font.ttf(await rootBundle.load("assets/fonts/alfont_com_Tasees-Bold.ttf"));
  // Or use a default font that supports Arabic (like 'Arial Unicode MS' if available)
  
  // Create PDF document
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(
        base: arabicFont, // Use the Arabic-supporting font
      ),
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl, // Right-to-left for Arabic
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
            // Header Row
                  pw.Row(
                  
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'اسم صاحب الشركة',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          ownerName,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                  
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'رقم الهاتف',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          ownerPhone,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                    ],
                  ),  
              // Header
              pw.Center(
                child: pw.Text(
                  'تفاصيل الحساب',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: arabicFont,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Table with borders
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                },
                children: [
                  
                  // Table Header
                  pw.TableRow(
                    children: [  pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'القيمة',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'المعلومات',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),  
                        ),
                      ),
                    
                    ],
                  ),
                  
                  // Customer Data Rows
                  _buildTableRow('الاسم', _currentCustomer.name),
                  _buildTableRow('رقم الهاتف', _currentCustomer.phoneNumber),
                  _buildTableRow('تاريخ الدفع', _currentCustomer.lastPaymentDate?? DateTime.now().toIso8601String()),
                  _buildTableRow('المبلغ المدفوع', '$paymentAmount جنيه'),
                  _buildTableRow('المبلغ المتبقي', '${_currentCustomer.balance.toStringAsFixed(2)} جنيه'),
                  
                  // Add more rows as needed
                ],
              ),
              
            
            ],
          ),
        );
      },
    ),
  );

  // Save to temporary file and share
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/customer_summary.pdf');
  await file.writeAsBytes(await pdf.save());
  
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'تفاصيل الفاتورة - ${_currentCustomer.name}',
    subject: 'تفاصيل الفاتورة',
  );
}
// Helper function to build table rows
pw.TableRow _buildTableRow(String label, String value) {
  return pw.TableRow(

    children: [
    
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(value),
      ),  pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(label),
      ),
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerCubit, List<Customer>>(
      listener: (context, state) {
        final updatedCustomer = state.firstWhere(
          (c) => c.name == _currentCustomer.name,
          orElse: () => _currentCustomer,
        );
        if (updatedCustomer != _currentCustomer) {
          setState(() {
            _currentCustomer = updatedCustomer;
            _cumulativeBalance = _calculateCumulativeBalance();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل العميل: ${_currentCustomer.name}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'حذف العميل',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تحذير'),
                    content: const Text('هل أنت متأكد من حذف هذا العميل؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CustomerCubit>().deleteCustomerTransactions(_currentCustomer.name);
                          Navigator.pop(context);
                        },
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton:
            _isProcessingPayment
                ? FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Colors.grey,
                  child: const CircularProgressIndicator(color: Colors.white),
                )
                : _cumulativeBalance > 0
                ? FloatingActionButton.extended(
                  onPressed: _showPaymentDialog,
                  icon: const Icon(Icons.payment),
                  label: const Text('تسديد دفعة'),
                  backgroundColor: Colors.green,
                )
                : null,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              'الاسم',
                              _currentCustomer.name,
                            ),
                          ),
                          BlocBuilder<BusinessCubit, BusinessOwner?>(
                            builder: (context, owner) {
                              return IconButton(
                                onPressed: () {
                                 shareAccountDetailsAsPdf(
                                  owner?.name ?? 'المالك',
                                  owner?.phone ?? 'رقم الهاتف',
                                 );
                                },
                                icon: Icon(Icons.share, color: Colors.blue),
                              );
                            },
                          ),
                        ],
                      ),
                      _buildInfoRow('رقم الهاتف', _currentCustomer.phoneNumber),
                      if (_currentCustomer.email != null)
                        _buildInfoRow(
                          'البريد الإلكتروني',
                          _currentCustomer.email!,
                        ),
                      if (_currentCustomer.address != null)
                        _buildInfoRow('العنوان', _currentCustomer.address!),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _cumulativeBalance > 0
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _cumulativeBalance > 0
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle,
                              color:
                                  _cumulativeBalance > 0
                                      ? Colors.red
                                      : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الرصيد التراكمي: ${_cumulativeBalance.toStringAsFixed(2)} جنيه',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    _cumulativeBalance > 0
                                        ? Colors.red
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'سجل الفواتير:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    _currentCustomer.transactions.isEmpty
                        ? const Center(child: Text('لا توجد فواتير مسجلة'))
                        : ListView.builder(
                          itemCount: _currentCustomer.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                _currentCustomer.transactions[_currentCustomer
                                        .transactions
                                        .length -
                                    1 -
                                    index];

                            // إخفاء الفواتير المسددة بالكامل
                            if (transaction.paymentMethod == 'أجل' &&
                                (transaction.paidAmount ?? 0) >=
                                    transaction.totalAmount) {
                              return const SizedBox.shrink();
                            }

                            return _buildTransactionCard(transaction);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(SaleTransaction transaction) {
    final isCredit = transaction.paymentMethod == 'أجل';
    final remainingAmount =
        transaction.totalAmount - (transaction.paidAmount ?? 0);
    final isPaid = remainingAmount <= 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color:
              isCredit
                  ? (isPaid
                      ? Colors.red.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3))
                  : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Icon(
          isCredit ? Icons.credit_card : Icons.payment,
          color:
              isCredit
                  ? (isPaid ? Colors.green : Colors.redAccent)
                  : Colors.blue,
          size: 32,
        ),
        title: Text(
          transaction.paymentMethod,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${transaction.totalAmount.toStringAsFixed(2)} جنيه'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransactionDetail('الكمية', '${transaction.quantity}'),
                _buildTransactionDetail(
                  'سعر الوحدة',
                  '${transaction.unitPrice?.toStringAsFixed(2)} جنيه',
                ),
                _buildTransactionDetail(
                  'الإجمالي',
                  '${transaction.totalAmount.toStringAsFixed(2)} جنيه',
                ),
                const Divider(),

                if (isCredit) ...[
                  _buildTransactionDetail(
                    'المبلغ المدفوع',
                    '${transaction.paidAmount?.toStringAsFixed(2) ?? '0.00'} جنيه',
                    color: Colors.green,
                  ),
                  _buildTransactionDetail(
                    'المبلغ المتبقي',
                    '${remainingAmount.toStringAsFixed(2)} جنيه',
                    color: remainingAmount > 0 ? Colors.red : Colors.green,
                  ),
                  _buildTransactionDetail(
                    'حالة الدفع',
                    isPaid ? 'مسددة بالكامل' : 'غير مسددة',
                    color: isPaid ? Colors.green : Colors.red,
                  ),
                  const Divider(),
                ],

                _buildTransactionDetail(
                  'طريقة الدفع',
                  transaction.paymentMethod,
                ),
                _buildTransactionDetail(
                  'التاريخ',
                  transaction.date != null
                      ? '${transaction.date!.day}/${transaction.date!.month}/${transaction.date!.year}'
                      : 'غير معروف',
                ),

                if (isCredit &&
                    transaction.paidAmount != null &&
                    transaction.paidAmount! > 0) ...[
                  const Divider(),
                  _buildTransactionDetail(
                    'تاريخ آخر دفعة',
                    transaction.date?.toString().substring(0, 10) ??
                        'غير معروف',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetail(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey[700],
            ),
          ),
          Text(value, style: TextStyle(color: color ?? Colors.black)),
        ],
      ),
    );
  }
}
