import 'package:al_safwa/features/home/presentation/manager/customers_cubit/customer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_safwa/features/home/data/models/customer.dart';

class FactoryScreen extends StatefulWidget {
  const FactoryScreen({super.key});

  @override
  State<FactoryScreen> createState() => _FactoryScreenState();
}

class _FactoryScreenState extends State<FactoryScreen> {
  final TextEditingController _productSearchController = TextEditingController();
  String _searchedProduct = '';
  Map<String, dynamic> _productStats = {};

  @override
  void dispose() {
    _productSearchController.dispose();
    super.dispose();
  }

  void _searchProduct(List<Customer> customers) {
    if (_searchedProduct.isEmpty) {
      setState(() => _productStats = {});
      return;
    }

    int quantity = 0;
    double totalAmount = 0;
    double paidAmount = 0;
    List<Map<String, dynamic>> transactions = [];

    for (var customer in customers) {
      for (var transaction in customer.transactions) {
        if (transaction.productName?.toLowerCase().contains(_searchedProduct.toLowerCase()) == true) {
          quantity += transaction.quantity ?? 0;
          totalAmount += transaction.totalAmount ?? 0;
          paidAmount += transaction.paidAmount ?? 0;
          transactions.add({
            'customer': customer.name,
            'quantity': transaction.quantity,
            'amount': transaction.totalAmount,
            'date': transaction.date,
          });
        }
      }
    }

    setState(() {
      _productStats = {
        'quantity': quantity,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'remaining': totalAmount - paidAmount,
        'transactions': transactions,
      };
    });
  }

  @override

  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade800,
          title: const Text('المصنع'),
          centerTitle: true,
        ),
        body: BlocBuilder<CustomerCubit, List<Customer>>(
          builder: (context, state) {
            // حساب الإحصائيات العامة
            int totalQuantitySold = 0;
            double totalBalance = 0;
            double solidBalance = 0;
      
            for (var customer in state) {
              for (var transaction in customer.transactions) {
                totalQuantitySold += transaction.quantity ?? 0;
                totalBalance += transaction.totalAmount ?? 0;
                solidBalance += transaction.paidAmount ?? 0;
              }
            }
      
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // حقل البحث عن المنتج
                    TextField(
                      controller: _productSearchController,
                      decoration: InputDecoration(
                        labelText: 'ابحث عن منتج',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(() => _searchedProduct = _productSearchController.text);
                            _searchProduct(state);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSubmitted: (value) {
                        setState(() => _searchedProduct = value);
                        _searchProduct(state);
                      },
                    ),
      
                    const SizedBox(height: 20),
      
                    // الإحصائيات العامة
                    _buildSectionTitle('الإحصائيات العامة'),
                    _buildStatisticCard(
                      children: [
                        _buildStatisticItem('إجمالي الكمية المباعة', totalQuantitySold),
                        _buildStatisticItem('إجمالي المبيعات', totalBalance, isCurrency: true),
                        _buildStatisticItem('المبلغ المحصل', solidBalance, isCurrency: true),
                        _buildStatisticItem('الرصيد المتبقي', totalBalance - solidBalance, 
                           isCurrency: true, isRemaining: true),
                      ],
                    ),
      
                    const SizedBox(height: 20),
      
                    // كتالوج المنتج المبحوث عنه
                    if (_searchedProduct.isNotEmpty) ...[
                      _buildSectionTitle('إحصائيات المنتج: $_searchedProduct'),
                      if (_productStats.isNotEmpty)
                        _buildStatisticCard(
                          children: [
                            _buildStatisticItem('الكمية المباعة', _productStats['quantity']),
                            _buildStatisticItem('إجمالي المبيعات', _productStats['totalAmount'], 
                               isCurrency: true),
                            _buildStatisticItem('المبلغ المحصل', _productStats['paidAmount'], 
                               isCurrency: true),
                            _buildStatisticItem('المتبقي', _productStats['remaining'], 
                               isCurrency: true, isRemaining: true),
                          ],
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('لا توجد نتائج لهذا المنتج'),
                        ),
      
                      const SizedBox(height: 10),
      
                      // تفاصيل معاملات المنتج
                      if (_productStats.isNotEmpty && _productStats['transactions'].length > 0) ...[
                        _buildSectionTitle('تفاصيل المعاملات'),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('العميل')),
                              DataColumn(label: Text('الكمية')),
                              DataColumn(label: Text('المبلغ')),
                              DataColumn(label: Text('التاريخ')),
                            ],
                            rows: (_productStats['transactions'] as List).map((t) {
                              return DataRow(cells: [
                                DataCell(Text(t['customer'] ?? '')),
                                DataCell(Text('${t['quantity']}')),
                                DataCell(Text('${t['amount']?.toStringAsFixed(2) ?? '0'} جنيه')),
                                DataCell(Text(t['date']?.toString() ?? '')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildStatisticCard({required List<Widget> children}) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildStatisticItem(String label, dynamic value, 
      {bool isCurrency = false, bool isRemaining = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            isCurrency ? '${value.toStringAsFixed(2)} جنيه' : value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isRemaining ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}