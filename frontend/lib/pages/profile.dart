import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';
import '../components/text_button.dart';
import '../components/popup.dart';

final user = FirebaseAuth.instance.currentUser!;

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();

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
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: Column (
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(
                      color: AppColors.color6,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.photoURL ?? ''),
                  ),
                ],
              )
            ),
            const SizedBox(height: 25),
            const Text(
              "Personal Details",
              style: TextStyle(
                color: AppColors.color6,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Name",
              style: TextStyle(
                color: AppColors.color6,
                fontSize: 18,
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user.displayName!,
              style: const TextStyle(
                color: AppColors.color6,
                fontSize: 15
              )
            ),
            const SizedBox(height: 15),
            const Text(
              "Email",
              style: TextStyle(
                color: AppColors.color6,
                fontSize: 18,
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user.email!,
              style: const TextStyle(
                color: AppColors.color6,
                fontSize: 15
              )
            ),
            Expanded(child: Container()),
            SizedBox(
              width: double.infinity,
              child: CustomTextButton(
                label: "Log out",
                onPressed:  () {
                  showDialog(
                    context: context,
                    builder: (context) => Popup(
                      title: "Are you sure you want to log out?", 
                      message: "Click OK to continue this action.",
                      onConfirm: () async {
                        authService.signOut(context);
                      },
                    )
                  );
                }
              ),
            )
          ],
        )
      )
    );
  }
}