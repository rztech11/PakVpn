import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/securelogin.png', // Add your onboarding image
                  height: 250,
                ),
              ),
              const SizedBox(height: 20),
              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: true),
                  _buildDot(),
                  _buildDot(),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Hide your IP and\nBrowse Safely',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Surf the web safely and securely\non the open internet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to signup or home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0BB283),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Start Your Free Trial',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  text: 'Have an Account? ',
                  style: const TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Sign in',
                      style: const TextStyle(
                        color: Color(0xFF0BB283),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0BB283) : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
