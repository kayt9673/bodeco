import 'package:fashion_app/app_colors.dart';
import 'package:flutter/material.dart';

class Popup extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const Popup({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = "OK",
    this.cancelText = "Cancel",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.color5,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.color6,
          fontSize: 20,
          fontWeight: FontWeight.bold
        )
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: AppColors.color6,
          fontSize: 15,
        )
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) onCancel!();
          },
          child: Text(
            cancelText,
            style: const TextStyle(
              color: AppColors.color6
            )
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.color1,
          ),
          child: Text(
            confirmText,
            style: const TextStyle(
              color: AppColors.color6
            )
          ),
        ),
      ],
    );
  }
}
