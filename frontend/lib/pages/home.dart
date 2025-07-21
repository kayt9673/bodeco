import 'package:fashion_app/pages/specific_item.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../components/search_bar.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];

  void _performSearch(str) async {
    try {
      final results = await ApiService.searchGoogle(str);
      setState(() {
        searchResults = results;
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
            Expanded(
              child: GridView.builder(
                itemCount: searchResults.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemBuilder: (context, index) {
                  final item = searchResults[index];

                  return GestureDetector(
                    onTap: () {
                      print(item['title']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecificItemPage(item: item),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item['image'] != null)
                              Image.network(
                                item['image'],
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item['title'] ?? 'No Title',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            )
          ],
        )
      )
    );
  }
}