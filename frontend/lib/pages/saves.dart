import 'package:fashion_app/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../components/item_grid.dart';

class SavesPage extends StatefulWidget {
  @override
  State<SavesPage> createState() => _SavesPageState();
}

class _SavesPageState extends State<SavesPage> {
  final userProfileService = UserProfileService();

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
            const Text(
              "My Saves",
              style: TextStyle(
                color: AppColors.color6,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: userProfileService.getUserSavedItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No saved items'));
                }
                return ItemGrid(items: snapshot.data!, onItemTapAfterReturn: () {setState(() {});},);
              },
            )
          ],
        )
      )
    );
  }
}