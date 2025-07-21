import 'package:fashion_app/components/text_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_colors.dart';
import '../components/popup.dart';


class SpecificItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const SpecificItemPage({super.key, required this.item});

  @override
  State<SpecificItemPage> createState() => _SpecificItemPageState();
}

class _SpecificItemPageState extends State<SpecificItemPage> {
  Future<void> launchLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
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
        padding: EdgeInsetsGeometry.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child:  ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                  )
                )
              )   
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Text(
                  "Brand",
                  style: TextStyle(
                    color: AppColors.color6,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Expanded(
                  child: Container()
                ),
                Text(
                  "\$1000",
                  style: TextStyle(
                    color: AppColors.color2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
            SizedBox(height: 20,),
            Text(
              item['title'],
              softWrap: true,
            ),
            Expanded(child: Container(),),
            Text(
              "Sustainability score: 7",
              style: TextStyle(
                color: AppColors.color2,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                SizedBox(
                  width: 160,
                  child: CustomTextButton(
                    label: "Save",
                    onPressed: (){}
                  ),
                ),
                Expanded(
                  child: Container()
                ),
                SizedBox(
                  width: 160,
                  child: CustomTextButton(
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