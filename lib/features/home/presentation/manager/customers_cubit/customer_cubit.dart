import 'package:bloc/bloc.dart';
import 'package:al_safwa/features/home/data/models/customer.dart';
import 'package:al_safwa/services/database_service.dart';
import '../../../data/models/sale_transaction.dart';

class CustomerCubit extends Cubit<List<Customer>> {
  CustomerCubit() : super([]);

  Future<void> loadCustomers() async {
    try {
      final customers = await DatabaseService.instance.getAllCustomers();
      for (var customer in customers) {
        customer.transactions = await DatabaseService.instance.getTransactionsForCustomer(customer.id!);
      }
      emit(customers);
    } catch (e) {
      print('Error loading customers: $e');
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await DatabaseService.instance.insertOrUpdateCustomer(customer);
      await loadCustomers(); // Refresh the customer list
    } catch (e) {
      print('Error adding customer: $e');
    }
  }

  Future<void> updateCustomer(String oldName, Customer updatedCustomer) async {
    try {
      await DatabaseService.instance.insertOrUpdateCustomer(updatedCustomer);
      await loadCustomers(); // Refresh the customer list
    } catch (e) {
      print('Error updating customer: $e');
    }
  }

  Future<void> deleteCustomer(String name) async {
    try {
      final customer = state.firstWhere((c) => c.name == name);
      if (customer.id != null) {
        await DatabaseService.instance.deleteCustomer(customer.id!);
        await DatabaseService.instance.deleteTransactionsForCustomer(customer.id!);
        await loadCustomers(); // Refresh the customer list
      }
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }

  Future<void> addTransaction(String customerName, SaleTransaction transaction) async {
    try {
      final customer = state.firstWhere((c) => c.name == customerName);
      if (customer.id != null) {
        final transactionId = await DatabaseService.instance.addTransaction(customer.id!, transaction);
        if (transactionId > 0) {
          await loadCustomers(); // Refresh all data
        }
      }
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      final success = await DatabaseService.instance.deleteTransaction(transactionId);
      if (success) {
        await loadCustomers(); // Refresh all data
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<double> pay(double amount, int customerId) async {
    try {
      // Get all transactions for customer
      final transactions = await DatabaseService.instance.getTransactionsForCustomer(customerId);
      
      // Sort transactions by date (oldest first)
      transactions.sort((a, b) => a.date.compareTo(b.date));
      
      double remainingPayment = amount;
      
      // Process each transaction
      for (var transaction in transactions) {
        if (remainingPayment <= 0) break;
        
        if (transaction.paymentMethod == 'أجل' &&
            (transaction.paidAmount ?? 0) < transaction.totalAmount) {
          
          double remainingInTransaction = 
              transaction.totalAmount - (transaction.paidAmount ?? 0);
          double paymentToApply = 
              remainingPayment > remainingInTransaction ? 
              remainingInTransaction : remainingPayment;
          
          // Update transaction with new payment
          final updatedTransaction = transaction.copyWith(
            paidAmount: (transaction.paidAmount ?? 0) + paymentToApply,
            lastPaymentDate: DateTime.now(),
            balanceAfterTransaction: remainingInTransaction - paymentToApply,
          );
          
          // Save updated transaction to database
          await DatabaseService.instance.updateTransaction(
            transaction.id!,
            updatedTransaction,
          );
          
          remainingPayment -= paymentToApply;
        }
      }
      
      // Refresh customer list to reflect changes
      await loadCustomers();
      
      // Return remaining unpaid amount
      return remainingPayment;
    } catch (e) {
      print('Error processing payment: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(int transactionId, SaleTransaction updatedTransaction) async {
    try {
      await DatabaseService.instance.updateTransaction(transactionId, updatedTransaction);
      await loadCustomers(); // Refresh the customer list
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }

  Future<void> getTransactionsForCustomer(int id) async {
    try {
      final customer = state.firstWhere((c) => c.id == id);
      if (customer.id != null) {
        final transactions = await DatabaseService.instance.getTransactionsForCustomer(customer.id!);
        customer.transactions = transactions;
        emit(List.from(state)); // Emit updated state
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Future<void> deleteCustomerTransactions(String customerName) async {
    try {
      final customer = state.firstWhere((c) => c.name == customerName);
      if (customer.id != null) {
        await DatabaseService.instance.deleteTransactionsForCustomer(customer.id!);
        await loadCustomers(); // Refresh the customer list
      }
    } catch (e) {
      print('Error deleting transactions: $e');
    }
  }
}