import 'package:fashion_app/components/text_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_colors.dart';
import '../components/popup.dart';
import '../services/user_profile_service.dart';
import '../services/api_service.dart';


class SpecificItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const SpecificItemPage({super.key, required this.item});

  @override
  State<SpecificItemPage> createState() => _SpecificItemPageState();
}

class _SpecificItemPageState extends State<SpecificItemPage> {
  final userProfileService = UserProfileService();
  bool isSaved = false;
  String? fallbackImage;

  @override
  void initState() {
    super.initState();
    checkIfItemIsSaved();
    fetchFallbackImageIfNeeded();
  }

  Future<void> checkIfItemIsSaved() async {
    final isAlreadySaved = await userProfileService.isItemAlreadySaved(widget.item['link']);
    setState(() {
      isSaved = isAlreadySaved;
    });
  }

  Future<void> launchLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> fetchFallbackImageIfNeeded() async {
    final hasImage = widget.item['image'] != null && widget.item['image'].toString().isNotEmpty;
    if (!hasImage) {
      try {
        final results = await ApiService.searchGoogle(widget.item['link']);
        if (results.isNotEmpty && results[0]['image'] != null) {
          setState(() {
            fallbackImage = results[0]['image'];
          });
        }
      } catch (e) {
        print("Failed to fetch fallback image: $e");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:  AppColors.color4,
      ),
      backgroundColor: AppColors.color4,
      body: 
      Padding(
        padding: const EdgeInsetsGeometry.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: (
                    widget.item['image'] != null && widget.item['image'].toString().isNotEmpty
                  )
                    ? Image.network(
                        widget.item['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Text('Image unavailable', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ),
                      )
                    : (fallbackImage != null)
                      ? Image.network(
                          fallbackImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Text('Image unavailable', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ),
                        )
                      : const Center(
                          child: Text('No image available', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ),

                )
              )   
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                Text(
                  (item['brand'] != null ) ? item['brand'] :  "Brand",
                  style: const TextStyle(
                    color: AppColors.color6,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Expanded(
                  child: Container()
                ),
                Text(
                  (item['price'] != null) ? "\$ ${item['price']}" : "\$1000",
                  style: const TextStyle(
                    color: AppColors.color2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
            const SizedBox(height: 20,),
            Text(
              item['title'],
              softWrap: true,
            ),
            Expanded(child: Container(),),
            Text(
              "Sustainability score: ${item['sustainability_score'] ?? 'N/A'}",
              style: const TextStyle(
                color: AppColors.color2,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                SizedBox(
                  width: 160,
                  child: CustomTextButton(
                    label: isSaved? "Unsave" : "Save",
                    onPressed: () async {
                      if (isSaved) {
                        await userProfileService.removeSavedItem(item['link']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item removed from saves!'),
                            backgroundColor: AppColors.color2,
                          )
                        );
                      } else {
                          await userProfileService.saveItemForUser(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item saved!'),
                              backgroundColor: AppColors.color2,
                            )
                          );
                      }
                      setState(() {
                        isSaved = !isSaved;
                      });
                    }
                  ),
                ),
                Expanded(
                  child: Container()
                ),
                SizedBox(
                  width: 160,
                  child: 
                  CustomTextButton(
                    label: "Buy",
                    backgroundColor: AppColors.color2,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => Popup(
                        title: "This will redirect you to a link in your browser", 
                        message: "Click OK to continue this action.",
                        onConfirm: () async {
                          launchLink(item['link']);
                        },
                      )
                    )
                  )
                )
              ],
            )
          ],
        )
      )
    );
  }
}