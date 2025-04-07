import 'package:al_safwa/features/admin/data/models/business_owner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BusinessCubit extends Cubit<BusinessOwner?> {
  BusinessCubit() : super(null);

  static const String _key = 'business_owner';

  Future<void> loadOwner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        emit(BusinessOwner.fromMap(json.decode(data)));
      }
    } catch (e) {
      print('Error loading owner data: $e');
    }
  }

  Future<bool> saveOwner(String name, String phone) async {
    try {
      final owner = BusinessOwner(name: name, phone: phone);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, json.encode(owner.toMap()));
      emit(owner);
      return true;
    } catch (e) {
      print('Error saving owner data: $e');
      return false;
    }
  }
  
}