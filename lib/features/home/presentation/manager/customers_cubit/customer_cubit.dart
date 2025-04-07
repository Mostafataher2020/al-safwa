import 'dart:convert';
import 'package:al_safwa/features/home/data/models/customer.dart';
import 'package:al_safwa/features/home/data/models/sale_transaction%20.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomerCubit extends Cubit<List<Customer>> {
  CustomerCubit() : super([]);

  Future<void> loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final customersJson = prefs.getString('customers') ?? '[]';
    final List<dynamic> decodedJson = jsonDecode(customersJson);
    final customers = decodedJson.map((json) => Customer.fromMap(json)).toList();
    emit(customers);
  }

  Future<void> addCustomer(Customer customer) async {
    if (state.any((c) => c.name == customer.name)) {
      throw Exception('يوجد عميل بنفس الاسم بالفعل!');
    }
    
    final prefs = await SharedPreferences.getInstance();
    final customers = List<Customer>.from(state)..add(customer);
    await _saveCustomers(prefs, customers);
    emit(customers);
  }

  Future<void> deleteCustomer(String customerName) async {
    final prefs = await SharedPreferences.getInstance();
    final customers = List<Customer>.from(state)
      ..removeWhere((c) => c.name == customerName);
    await _saveCustomers(prefs, customers);
    emit(customers);
  }

  Future<void> deleteCustomerTransactions(String customerName) async {
    final prefs = await SharedPreferences.getInstance();
    final customers = state.map((customer) {
      if (customer.name == customerName) {
        return Customer(
          name: customer.name,
          phoneNumber: customer.phoneNumber,
          email: customer.email,
          address: customer.address,
          imageUrl: customer.imageUrl,
          transactions: [], // حذف جميع المعاملات
        );
      }
      return customer;
    }).toList();
    await _saveCustomers(prefs, customers);
    emit(customers);
  }

  Future<void> addTransaction(String customerName, SaleTransaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final customers = state.map((customer) {
      if (customer.name == customerName) {
        return customer.addTransaction(transaction);
      }
      return customer;
    }).toList();
    
    await _saveCustomers(prefs, customers);
    emit(customers);
  }

  Future<void> updateCustomer(String oldName, Customer updatedCustomer) async {
    if (oldName != updatedCustomer.name && 
        state.any((c) => c.name == updatedCustomer.name)) {
      throw Exception('يوجد عميل بنفس الاسم بالفعل!');
    }
    
    final prefs = await SharedPreferences.getInstance();
    final customers = state.map((customer) {
      return customer.name == oldName ? updatedCustomer : customer;
    }).toList();

    await _saveCustomers(prefs, customers);
    emit(customers);
  }

  Future<void> _saveCustomers(SharedPreferences prefs, List<Customer> customers) async {
    final customersJson = jsonEncode(customers.map((c) => c.toMap()).toList());
    await prefs.setString('customers', customersJson);
  }

  List<Customer> searchCustomers(String query) {
    return state.where((customer) => 
      customer.name.toLowerCase().contains(query.toLowerCase()) ||
      customer.phoneNumber.contains(query)
    ).toList();
  }

  List<Customer> getCustomersWithDebt() {
    return state.where((customer) => customer.balance > 0).toList();
  }

  updateCustomerBalance(String name, double newBalance) {}
Future<void> updateCustomer2(String oldName, Customer updatedCustomer) async {
  final prefs = await SharedPreferences.getInstance();
  final updatedList = state.map((c) => c.name == oldName ? updatedCustomer : c).toList();
  
  await prefs.setString('customers', jsonEncode(updatedList.map((c) => c.toMap()).toList()));
  emit(List.from(updatedList));
}
}