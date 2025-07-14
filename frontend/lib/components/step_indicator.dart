import 'package:flutter/material.dart';
import 'package:fashion_app/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double width;
  final double height;
  final double spacing;
  final Color activeColor;
  final Color inactiveColor;

  const StepIndicator({
    Key? key,
    required this.totalSteps,
    required this.currentStep,
    this.width = 24,
    this.height = 8,
    this.spacing = 6,
    this.activeColor = AppColors.color2,
    this.inactiveColor = AppColors.color5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        );
      }),
    );
  }
}
