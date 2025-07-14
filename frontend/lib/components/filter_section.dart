import 'package:flutter/material.dart';
import '../app_colors.dart';

Widget buildFilterSection({
  required String title,
  int? selectedCount,
  required List<Widget> children,
}) {
  return ExpansionTile(
    title: Text(title, 
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.color6)
      ),
    trailing: selectedCount != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: AppColors.color1,
              shape: BoxShape.circle,
            ),
            child: Text(
              selectedCount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.color4
              ),
            ),
          )
        : const Icon(Icons.expand_more),
    childrenPadding: const EdgeInsets.only(top: 8, bottom: 16),
    children: children,
  );
} 