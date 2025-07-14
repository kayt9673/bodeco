import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../components/filter_section.dart';


class FilterPage extends StatefulWidget {
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color4,
      appBar: AppBar(
        backgroundColor: AppColors.color4,
        title: const Text(
          "Filters",
          style: TextStyle(
            color: AppColors.color6,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsGeometry.only(right:20), 
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Clear All",
                style: TextStyle(
                  color: AppColors.color2
                )
              )
            )
          )
        ]
      ),
      body: ListView(
        children: [
          buildFilterSection(
            title: 'Color',
            selectedCount: 1,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(label: const Text("BLACK"), selected: true, onSelected: (_) {}),
                  FilterChip(label: const Text("WHITE"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("GREY"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("YELLOW"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("BLUE"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("PURPLE"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("GREEN"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("RED"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("PINK"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("ORANGE"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("GOLD"), selected: false, onSelected: (_) {}),
                  FilterChip(label: const Text("SILVER"), selected: false, onSelected: (_) {}),
                ],
              )
            ],
          ),
        ]
      )
    );
  }
}