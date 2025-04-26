import 'package:al_safwa/features/admin/data/models/business_owner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_safwa/services/database_service.dart';

class BusinessCubit extends Cubit<BusinessOwner?> {
  BusinessCubit() : super(null);

  Future<void> loadOwner() async {
    try {
      final owner = await DatabaseService.instance.getBusinessOwner();
      emit(owner);
    } catch (e) {
      print('Error loading owner data: $e');
    }
  }

  Future<bool> saveOwner(String name, String phone, String factory) async {
    try {
      final owner = BusinessOwner(name: name, phone: phone, factory: factory);
      await DatabaseService.instance.insertOrUpdateBusinessOwner(owner);
      emit(owner);
      return true;
    } catch (e) {
      print('Error saving owner data: $e');
      return false;
    }
  }
}