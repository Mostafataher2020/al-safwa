import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_safwa/features/home/data/models/customer.dart';
import 'package:al_safwa/features/home/presentation/manager/customers_cubit/customer_cubit.dart';
import 'package:al_safwa/features/home/presentation/views/add_customer_screen.dart';
import 'package:al_safwa/features/home/presentation/views/widgets/customer_details_page.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(context),
      body: _buildCustomerList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('قائمة العملاء'),
      centerTitle: true,
      backgroundColor: Colors.blue.shade800,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _navigateToAddScreen(context),
      child: const Icon(Icons.add),
      backgroundColor: Colors.blue.shade800,
    );
  }

  Widget _buildCustomerList() {
    return BlocBuilder<CustomerCubit, List<Customer>>(
      builder: (context, customers) {
        if (customers.isEmpty) {
          return const Center(child: Text('لا يوجد عملاء مسجلين'));
        }

        final filteredCustomers = _filterCustomers(customers, _searchQuery);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن عميل...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  return _buildCustomerCard(context, customer);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<Customer> _filterCustomers(List<Customer> customers, String query) {
    if (query.isEmpty) return customers;
    
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase()) ||
             customer.phoneNumber.contains(query);
    }).toList();
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child: Text(customer.name[0]),
          backgroundColor: Colors.blue.shade100,
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(customer.phoneNumber),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToEditScreen(context, customer),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, customer),
            ),
          ],
        ),
        onTap: () => _navigateToDetailsScreen(context, customer),
      ),
    );
  }

  void _navigateToAddScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customer: customer),
      ),
    );
  }

  void _navigateToDetailsScreen(BuildContext context, Customer customer) {
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider.value(
      value: BlocProvider.of<CustomerCubit>(context),
      child: CustomerDetailsScreen(customer: customer),
    ),
  ),
);
  }

  Future<void> _confirmDelete(BuildContext context, Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف العميل ${customer.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<CustomerCubit>().deleteCustomer(customer.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف ${customer.name}')),
      );
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('بحث عن عميل'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: 'ادخل اسم العميل أو رقم الهاتف'),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }
}