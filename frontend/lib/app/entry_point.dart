import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../pages/Navigation.dart';
import '../pages/onboarding.dart';
import '../pages/loading_screen.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool _checkingAuth = true;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _checkIfSignedIn();
  }

  Future<void> _checkIfSignedIn() async {
  try {
    // SIGN OUT USER FOR TESTING PURPOSES
    // await GoogleSignIn().signOut();

    final GoogleSignInAccount? user = await GoogleSignIn().signInSilently();

    if (user != null) {
      setState(() {
        _isSignedIn = true;
      });
    }
  } catch (e) {
    // Sign-in check error
  } finally {
    if (mounted) {
      setState(() {
        _checkingAuth = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) return const LoadingScreen();
    return _isSignedIn ? const NavigationPage() : OnboardingPage();
  }
}
