import 'package:flutter/material.dart';
import '../pages/specific_item.dart';
import '../services/api_service.dart';

class ItemGrid extends StatefulWidget {
  final List<dynamic> items;
  final VoidCallback? onItemTapAfterReturn;

  const ItemGrid({
    super.key,
    required this.items,
    this.onItemTapAfterReturn,
  });

  @override
  State<ItemGrid> createState() => _ItemGridState();
}

class _ItemGridState extends State<ItemGrid> {
  final Map<int, String?> fallbackImages = {};

  Future<void> fetchFallbackImage(int index, String link) async {
    if (fallbackImages.containsKey(index)) return;

    try {
      final results = await ApiService.searchGoogle(link);
      if (results.isNotEmpty && results[0]['image'] != null) {
        setState(() {
          fallbackImages[index] = results[0]['image'];
        });
      } else {
        setState(() {
          fallbackImages[index] = null;
        });
      }
    } catch (e) {
      print("Failed to fetch image for $link: $e");
      setState(() {
        fallbackImages[index] = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        itemCount: widget.items.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final imageUrl = item['image'];
          
          final hasImage = imageUrl != null && imageUrl.toString().isNotEmpty;

          if (!hasImage) {
            fetchFallbackImage(index, item['link']);
          }

          final displayImage = hasImage ? imageUrl : fallbackImages[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpecificItemPage(item: item),
                ),
              );
              widget.onItemTapAfterReturn?.call();
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
                    displayImage != null
                        ? Image.network(
                            displayImage,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 120,
                                color: Colors.grey[300],
                                child:
                                    const Icon(Icons.broken_image, size: 40),
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            height: 120,
                            color: Colors.grey[300],
                            child:
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item['title'] ?? 'No Title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
