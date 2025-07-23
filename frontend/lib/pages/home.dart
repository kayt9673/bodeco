import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../components/search_bar.dart';
import '../services/api_service.dart';
import '../components/item_grid.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool searching = false;

  void _performSearch(str) async {
    try {
      final results = await ApiService.searchGoogle(str);
      setState(() {
        searchResults = results;
        searching = true;
        print("Search results received: $results");
      });
    } catch (e) {
      print("Search failed: $e");
    }
  }

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
            CustomSearchBar(controller: _searchController, onSubmitted: _performSearch,),
            const SizedBox(height: 25),
            const Text(
              "Shop By Category",
              style: TextStyle(
                color: AppColors.color6,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),

            FutureBuilder<List<dynamic>>(
              future: ApiService.fetchScoredItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items found.'));
                } else if (!searching) {
                  return ItemGrid(items: snapshot.data!);
                }
                return ItemGrid(items: searchResults);
              },
            )

          ],
        )
      )
    );
  }
}