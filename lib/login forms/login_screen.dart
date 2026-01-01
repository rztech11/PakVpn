import 'package:flutter/material.dart';
import 'login_form.dart';
import 'googleauth.dart';
import 'signup.dart'; // ✅ Import your signup form screen

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // 🔹 Handle Google Sign-In Button Press
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final user = await GoogleAuthService().signInWithGoogle();

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome, ${user.displayName ?? 'User'}!")),
      );

      // Example navigation (replace with your screen)
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomeScreen()),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            // 🔹 Logo
            Center(
              child: Image.asset(
                "assets/logo.png",
                width: 200,
                height: 200,
              ),
            ),

            // 🔹 Tagline
            const Text(
              "Login now to access faster internet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Login with Email Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmailLoginForm()),
                  );
                },
                icon: const Icon(Icons.email, color: Colors.white),
                label: const Text(
                  "Login With Email",
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Login with Google Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleGoogleSignIn(context),
                icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                label: const Text(
                  "Login With Google",
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Signup Text (Clickable)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text.rich(
                TextSpan(
                  text: "Don’t have an account? ",
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: "Signup",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
