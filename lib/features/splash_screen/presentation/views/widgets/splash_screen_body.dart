import 'package:al_safwa/features/home/presentation/views/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreenBody extends StatefulWidget {
  const SplashScreenBody({super.key});

  @override
  State<SplashScreenBody> createState() => _SplashScreenBodyState();
}

class _SplashScreenBodyState extends State<SplashScreenBody> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  /*************  ✨ Codeium Command ⭐  *************/
  /// Returns a [Stack] widget containing the UI for the splash screen.
  /******  380aeda6-6f3a-44e8-9523-349c21e19352  *******/
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white,Colors.white],begin: Alignment.topLeft,end: Alignment.bottomRight),
        image:DecorationImage(image: AssetImage('assets/images/alsafwa.jpg'),fit: BoxFit.fill),
      ),
      
    );
  }
}
