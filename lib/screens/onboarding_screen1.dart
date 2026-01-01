import 'package:flutter/material.dart';
import 'package:pakvpnn/login forms/login_screen.dart';
import 'package:pakvpnn/login forms/signup.dart'; // ✅ Make sure paths are correct

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/datasecurity.png",
      "title": "Secure Browsing\nWith no limits",
      "subtitle": "We are committed to always putting\nyour safety first"
    },
    {
      "image": "assets/securelogin.png",
      "title": "Hide your IP and\nbrowse safely",
      "subtitle": "Surf the web safely and securely\non the open internet"
    },
    {
      "image": "assets/dataprivacy.png",
      "title": "Your Data Privacy\nis our Priority",
      "subtitle": "We are committed to always putting\nyour privacy first"
    },
  ];

  void _onSkip() {
    _pageController.jumpToPage(onboardingData.length - 1);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 12 : 8,
      height: _currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF0BB283) : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

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
              const SizedBox(height: 10),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Image.asset(
                          onboardingData[index]['image']!,
                          height: 250,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            onboardingData.length,
                                (dotIndex) => _buildDot(dotIndex),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          onboardingData[index]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ✅ Get Started → Signup
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0BB283),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'GET STARTED',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Sign in tappable text
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Have an Account? ',
                    style: TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          color: Color(0xFF0BB283),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _onSkip,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
