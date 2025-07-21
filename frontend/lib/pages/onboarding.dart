import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';
import '../components/step_indicator.dart';


class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final authService = AuthService();
  int currentStep = 0;

  final List<Map<String,String>> onboardingTexts = [
    {
      'title': 'Welcome to bodeco',
      'subtitle1': 'Sustainable fashion, made simple.',
      'subtitle2': 'Discover styles you love—without costing the Earth.',
    },
    {
      'title': 'Why it matters',
      'subtitle1': 'Fashion is one of the world\'s biggest polluters.',
      'subtitle2': 'With bodeco, every choice helps reduce waste and save resources.',
    },
    {
      'title': 'Our Promise',
      'subtitle1': 'Transparency always',
      'subtitle2': 'We rate every item for sustainability, so you can shop smarter and feel good about your impact.',
    },
  ];

  void _nextStep() {
    setState(() {
      if (currentStep < onboardingTexts.length - 1) {
        currentStep++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentContent = onboardingTexts[currentStep];

    return Scaffold(
      backgroundColor: AppColors.color4,
      body: Padding(
        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 20, bottom: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding (
              padding: const EdgeInsets.only(top: 200.0),
              child: Image.asset('assets/images/fruitstand.png')
            ),
            Column(
              children: [
                Text(
                  currentContent['title']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.color6,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  currentContent['subtitle1']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.color6,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  currentContent['subtitle2']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.color6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],),
              StepIndicator(
                totalSteps: 3,
                currentStep: currentStep,
              ),
              SizedBox(
                width: 250,
                child: 

                  // Sign in button
                
                  currentStep == onboardingTexts.length - 1
                    ? ElevatedButton.icon(
                        onPressed: () async {
                          authService.signInWithGoogle(context);
                        },
                        icon: Image.asset(
                          'assets/images/google_icon.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'SIGN IN WITH GOOGLE',
                          style: TextStyle(
                            color: AppColors.color4,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color6,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          elevation: 1,
                        ),
                      )
                    
                    // Next step button

                    : ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color1,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            color: AppColors.color6,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
          ],
        ))
    );
  }
}