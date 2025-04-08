import 'package:al_safwa/features/admin/presentation/manager/admin_cubit/business_cubit.dart';
import 'package:al_safwa/features/home/presentation/manager/customers_cubit/customer_cubit.dart';
import 'package:al_safwa/features/splash_screen/presentation/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final businessCubit = BusinessCubit();
  await businessCubit.loadOwner(); // تحميل البيانات قبل تشغيل التطبيق

  runApp(MyApp(businessCubit: businessCubit));
}

class MyApp extends StatelessWidget {
  final BusinessCubit businessCubit;
  const MyApp({super.key, required this.businessCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CustomerCubit()..loadCustomers()),

        // ✅ استخدم BlocProvider.value بدلاً من إعادة إنشاء BusinessCubit
        BlocProvider.value(value: businessCubit),
      ],
      child: MaterialApp(
        title: 'إدارة العملاء',
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
