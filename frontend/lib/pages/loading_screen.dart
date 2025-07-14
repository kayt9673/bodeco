import 'package:flutter/material.dart';
import '../app_colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color1,
      body: Center(
        child: Padding (
          padding: const EdgeInsets.all(100),
          child: Image.asset('assets/images/bodeco_logo.png')
        )
      ),
    );
  }
}
