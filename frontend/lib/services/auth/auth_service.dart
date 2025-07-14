import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../pages/navigation.dart';
import '../../pages/onboarding.dart';

class AuthService {
  
  Future<void> signInWithGoogle(BuildContext context) async {

    final user = await GoogleSignIn().signIn();
    GoogleSignInAuthentication userAuth = await user!.authentication;
    var credential = GoogleAuthProvider.credential(idToken: userAuth.idToken, accessToken: userAuth.accessToken);
    await FirebaseAuth.instance.signInWithCredential(credential);
    final firebaseUser =  FirebaseAuth.instance.currentUser;
    
    if ( firebaseUser != null && context.mounted) {
      Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const NavigationPage())
        );
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OnboardingPage()),
        (route) => false, // remove all previous routes
      );
    }
  }
}
