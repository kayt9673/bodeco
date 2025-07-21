import 'package:fashion_app/app_colors.dart';
import 'package:flutter/material.dart';
import '../pages/filter.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hintText;
  final ValueChanged<String>? onSubmitted;


  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.hintText = 'Search',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.color5,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: AppColors.color6,
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              onSubmitted: onSubmitted,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                icon: const Icon(Icons.search),
                hintText: hintText,
                border: InputBorder.none,
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          if (onChanged != null) onChanged!('');
                        },
                      )
                    : null,
              ),
            )
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FilterPage())
              );
            },
            icon: const Icon(
              Icons.tune,
              color: AppColors.color1,
            )
          )
        ],
      )
    );
  }
}
