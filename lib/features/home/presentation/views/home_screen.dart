import 'package:al_safwa/features/admin/presentation/views/business_owner_screen.dart';
import 'package:al_safwa/features/home/presentation/views/customers_screen.dart';
import 'package:al_safwa/features/home/presentation/views/factory_screen.dart';
import 'package:al_safwa/features/home/presentation/views/saless_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen
 extends StatefulWidget {
  const HomeScreen
  ({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    int _selectedIndex = 0; // المتغير اللي بيحدد الصفحة الحالية

  // قائمة الصفحات
  final List<Widget> _pages = [
    CustomersScreen(),
    SalesScreen(),
    FactoryScreen(),
    BusinessOwnerScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.blue.shade800,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "المبيعات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.factory),
            label: "المصنع",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "الإعدادات",
          ),
        ],
      ),
    );
  }
}

// صفحات التطبيق





