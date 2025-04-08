import 'package:al_safwa/features/splash_screen/presentation/views/widgets/splash_screen_body.dart';
import 'package:flutter/material.dart';

class SplashScreen
 extends StatelessWidget {
  const SplashScreen
  ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashScreenBody(),
    );
  }
}