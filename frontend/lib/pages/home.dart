import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../components/search_bar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color4,
      body: 
      Padding(
        padding: const EdgeInsets.only(top: 70, right: 30, left: 30, bottom: 30),
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "bodeco",
              style: TextStyle(
                color: AppColors.color1,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 25),
            CustomSearchBar(controller: _searchController),
            const SizedBox(height: 25),
            const Text(
              "Shop By Category",
              style: TextStyle(
                color: AppColors.color6,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        )
      )
    );
  }
}