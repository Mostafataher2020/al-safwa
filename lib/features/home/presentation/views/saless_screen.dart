import 'package:al_safwa/features/home/data/models/sale_transaction%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_safwa/features/home/presentation/manager/customers_cubit/customer_cubit.dart';
import 'package:al_safwa/features/home/data/models/customer.dart';

class SalesScreen extends StatefulWidget {
  final Customer? initialCustomer;

  const SalesScreen({Key? key, this.initialCustomer}) : super(key: key);

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _paidAmountController = TextEditingController();

  String _paymentMethod = 'كاش';
  double _totalAmount = 0.0;
  Customer? _selectedCustomer;
  bool _isPartialPayment = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomer != null) {
      _selectedCustomer = widget.initialCustomer;
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _formKey.currentState?.reset();
    _productNameController.clear();
    _quantityController.clear();
    _priceController.clear();
    _paidAmountController.clear();
    setState(() {
      _paymentMethod = 'كاش';
      _totalAmount = 0.0;
      _isPartialPayment = false;
    });
  }

Future<void> _saveTransaction() async {
  if (_selectedCustomer == null) return;

  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final quantity = int.parse(_quantityController.text);
    final unitPrice = double.parse(_priceController.text);
    final totalAmount = quantity * unitPrice;
    final paidAmount = _isPartialPayment ? double.parse(_paidAmountController.text) : 0.0;

    if (_isPartialPayment && _paymentMethod == 'أجل') {
      if (paidAmount <= 0) {
        throw 'يجب أن يكون المبلغ المدفوع أكبر من صفر';
      }
      if (paidAmount >= totalAmount) {
        throw 'المبلغ المدفوع يجب أن يكون أقل من إجمالي الفاتورة';
      }
    }

    // حساب الرصيد بنفس طريقة CustomerDetailsScreen
    double balance = 0.0;
    bool hasCreditTransactions = false;
    
    for (var transaction in _selectedCustomer!.transactions) {
      if (transaction.paymentMethod == 'أجل') {
        hasCreditTransactions = true;
        if (transaction.isPayment) {
          balance -= transaction.paidAmount;
        } else {
          balance += (transaction.quantity! * transaction.unitPrice!);
        }
      }
    }
    
    double currentBalance = hasCreditTransactions ? balance : _selectedCustomer!.balance;
    double newBalance = currentBalance;

    if (_paymentMethod == 'أجل') {
      newBalance = currentBalance + totalAmount;
      if (_isPartialPayment) {
        newBalance -= paidAmount;
      }
    }

    // إنشاء معاملة البيع بدون حفظ إجمالي الفاتورة
    final saleTransaction = SaleTransaction(
      date: DateTime.now(),
      productName: _productNameController.text,
      quantity: quantity,
      unitPrice: unitPrice,
      paymentMethod: _paymentMethod,
      paidAmount: _paymentMethod == 'كاش' ? totalAmount : paidAmount,
      isPayment: false,
      balanceAfterTransaction: newBalance,
    );

    // حفظ معاملة البيع
    await context.read<CustomerCubit>().addTransaction(
      _selectedCustomer!.name,
      saleTransaction,
    );

    // حفظ معاملة الدفع إذا كانت جزئية
    if (_isPartialPayment && _paymentMethod == 'أجل') {
      final paymentTransaction = SaleTransaction(
        date: DateTime.now(),
        paymentMethod: _paymentMethod,
        paidAmount: paidAmount,
        isPayment: true,
        balanceAfterTransaction: newBalance,
      );
      
      await context.read<CustomerCubit>().addTransaction(
        _selectedCustomer!.name,
        paymentTransaction,
      );
    }

    // عرض رسالة نجاح مختصرة جداً
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم الحفظ بنجاح'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );

    _clearFields();
    
    // تحديث الواجهة
    if (mounted) {
      setState(() {});
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حدث خطأ: ${e.toString()}'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
  double _calculateNewBalance() {
  if (_selectedCustomer == null) return 0.0;
  
  final currentBalance = _selectedCustomer!.balance;
  final totalAmount = double.parse(_quantityController.text) * double.parse(_priceController.text);
  final paidAmount = _isPartialPayment ? double.parse(_paidAmountController.text) : 0;
  
  if (_paymentMethod == 'كاش') {
    return currentBalance; // لا يتغير الرصيد في حالة الدفع كاش
  } else {
    if (_isPartialPayment) {
      // في حالة الأجل مع دفع جزئي: نضيف فقط المبلغ المتبقي
      return currentBalance + (totalAmount - paidAmount);
    } else {
      // في حالة الأجل بدون دفع جزئي: نضيف إجمالي الفاتورة
      return currentBalance + totalAmount;
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'صفحة المبيعات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 10,
        shadowColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProductNameField(),
                const SizedBox(height: 16),
                _buildQuantityField(),
                const SizedBox(height: 16),
                _buildPriceField(),
                const SizedBox(height: 16),
                _buildPaymentMethodDropdown(),
                const SizedBox(height: 16),
                _buildCustomerDropdown(context),
                const SizedBox(height: 16),
                if (_paymentMethod == 'أجل') _buildPartialPaymentSwitch(),
                if (_paymentMethod == 'أجل' && _isPartialPayment)
                  _buildPaidAmountField(),
                const SizedBox(height: 24),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductNameField() {
    return TextFormField(
      controller: _productNameController,
      decoration: InputDecoration(
        labelText: 'اسم المنتج',
        prefixIcon: Icon(Icons.shopping_cart, color: Colors.blue.shade800),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'برجاء إدخال اسم المنتج' : null,
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      decoration: InputDecoration(
        labelText: 'عدد القطع',
        prefixIcon: Icon(Icons.format_list_numbered, color: Colors.blue.shade800),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'برجاء إدخال عدد القطع';
        if (double.tryParse(value!) == null) return 'برجاء إدخال رقم صحيح';
        if (double.parse(value) <= 0) return 'يجب أن يكون العدد أكبر من صفر';
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'سعر القطعة',
        prefixIcon: Icon(Icons.attach_money, color: Colors.blue.shade800),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'برجاء إدخال سعر القطعة';
        if (double.tryParse(value!) == null) return 'برجاء إدخال رقم صحيح';
        if (double.parse(value) <= 0) return 'يجب أن يكون السعر أكبر من صفر';
        return null;
      },
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      value: _paymentMethod,
      decoration: InputDecoration(
        labelText: 'طريقة الدفع',
        prefixIcon: Icon(Icons.payment, color: Colors.blue.shade800),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ['كاش', 'أجل'].map((method) => DropdownMenuItem(
        value: method,
        child: Text(method),
      )).toList(),
      onChanged: (value) => setState(() {
        _paymentMethod = value!;
        if (_paymentMethod == 'كاش') {
          _isPartialPayment = false;
        }
      }),
    );
  }

  Widget _buildCustomerDropdown(BuildContext context) {
    return BlocBuilder<CustomerCubit, List<Customer>>(
      builder: (context, customers) {
        return DropdownButtonFormField<Customer>(
          value: _selectedCustomer,
          decoration: InputDecoration(
            labelText: 'اختر العميل',
            prefixIcon: Icon(Icons.person, color: Colors.blue.shade800),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: customers.map((customer) => DropdownMenuItem(
            value: customer,
            child: Text(customer.name),
          )).toList(),
          onChanged: (customer) => setState(() => _selectedCustomer = customer),
          validator: (value) => value == null ? 'برجاء اختيار عميل' : null,
        );
      },
    );
  }

  Widget _buildPartialPaymentSwitch() {
    return SwitchListTile(
      title: const Text('دفع جزء من المبلغ'),
      value: _isPartialPayment,
      onChanged: (value) => setState(() => _isPartialPayment = value),
    );
  }

  Widget _buildPaidAmountField() {
    return TextFormField(
      controller: _paidAmountController,
      decoration: InputDecoration(
        labelText: 'المبلغ المدفوع',
        prefixIcon: Icon(Icons.money, color: Colors.blue.shade800),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (_paymentMethod == 'أجل' && _isPartialPayment && (value?.isEmpty ?? true)) {
          return 'برجاء إدخال المبلغ المدفوع';
        }
        if (_isPartialPayment && double.tryParse(value ?? '0') == null) {
          return 'برجاء إدخال مبلغ صحيح';
        }
        if (_isPartialPayment && double.parse(value!) <= 0) {
          return 'يجب أن يكون المبلغ أكبر من صفر';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSaving ? null : () => _handleSubmit(context),
      child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'حفظ الفاتورة',
              style: TextStyle(fontSize: 18),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // التحقق من أن القيم أرقام صحيحة
    final quantity = double.tryParse(_quantityController.text);
    final price = double.tryParse(_priceController.text);
    if (quantity == null || price == null || quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('برجاء إدخال أرقام صحيحة أكبر من صفر')),
      );
      return;
    }

    // حساب المبلغ الإجمالي
    setState(() {
      _totalAmount = quantity * price;
    });

    if (_paymentMethod == 'أجل' && _isPartialPayment) {
      final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;
      if (paidAmount > _totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('المبلغ المدفوع أكبر من إجمالي الفاتورة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (paidAmount == _totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('إذا كان المبلغ المدفوع يساوي الإجمالي، يرجى تغيير طريقة الدفع إلى كاش'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final shouldSave = await _showInvoiceDialog(context);
    if (shouldSave ?? false) {
      await _saveTransaction();
    }
  }

Future<bool?> _showInvoiceDialog(BuildContext context) {
  final paidAmount = _isPartialPayment ? double.parse(_paidAmountController.text) : 0.0;
  final totalAmount = double.parse(_quantityController.text) * double.parse(_priceController.text);
  final remainingAmount = _paymentMethod == 'أجل' ? (totalAmount - paidAmount) : 0.0;
  final newBalance = _calculateNewBalance();

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تفاصيل الفاتورة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceDetailRow('العميل:', _selectedCustomer?.name ?? 'غير محدد'),
            const Divider(),
            _buildInvoiceDetailRow('اسم المنتج:', _productNameController.text),
            _buildInvoiceDetailRow('الكمية:', _quantityController.text),
            _buildInvoiceDetailRow('سعر الوحدة:', _priceController.text),
            const Divider(),
            _buildInvoiceDetailRow('طريقة الدفع:', _paymentMethod),
            _buildInvoiceDetailRow('إجمالي الفاتورة:', '${totalAmount.toStringAsFixed(2)} جنيه'),
            
            if (_paymentMethod == 'أجل') ...[
              if (_isPartialPayment) _buildInvoiceDetailRow('المبلغ المدفوع:', '${paidAmount.toStringAsFixed(2)} جنيه'),
              _buildInvoiceDetailRow('المبلغ المضاف للرصيد:', '${(_paymentMethod == 'أجل' ? (totalAmount - paidAmount) : 0).toStringAsFixed(2)} جنيه'),
              const Divider(),
              // _buildInvoiceDetailRow(
              //   'الرصيد الجديد للعميل:',
              //   '${newBalance.toStringAsFixed(2)} جنيه',
              //   valueStyle: TextStyle(
              //     color: newBalance > 0 ? Colors.red : Colors.green,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('حفظ الفاتورة'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    ),
  );
}

  Widget _buildInvoiceDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}