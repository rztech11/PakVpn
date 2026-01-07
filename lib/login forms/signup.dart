import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^\S+@\S+\.\S+$').hasMatch(email);
  }

  Future<void> _signupUser() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final pass = _passwordController.text.trim();

      // ✅ Create Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final user = userCredential.user;
      if (user == null) {
        setState(() => _loading = false);
        _showMsg("Signup failed: user is null.");
        return;
      }

      // ✅ Update display name
      await user.updateDisplayName(name);

      // ✅ Send verification email (this proves the email is real/owned)
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      // ✅ Save profile to Firestore
      await _db.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "emailVerified": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() => _loading = false);

      // ✅ Force verify first: sign out and go to login
      await _auth.signOut();

      _showMsg(
        "Verification email sent to $email.\nPlease verify your email, then login.",
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const EmailLoginForm()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _loading = false);

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'network-request-failed':
          message = 'No internet connection. Please try again.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password signup is not enabled in Firebase.';
          break;
        default:
          message = 'Auth error: ${e.code} - ${e.message ?? ""}';
      }

      _showMsg(message);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _showMsg("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 156,
                  height: 156,
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Login now to access faster internet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Full name'),
                        _whiteField(
                          controller: _nameController,
                          hint: 'Full name',
                          validator: (value) =>
                          value!.trim().isEmpty ? 'Please enter your full name' : null,
                        ),
                        const SizedBox(height: 12),

                        _label('Email'),
                        _whiteField(
                          controller: _emailController,
                          hint: 'Email',
                          validator: (value) {
                            final v = value?.trim() ?? "";
                            if (v.isEmpty) return 'Please enter your email';
                            if (!_isValidEmail(v)) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _label('Phone'),
                        _whiteField(
                          controller: _phoneController,
                          hint: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.trim().isEmpty
                              ? 'Please enter your phone number'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        _label('Password'),
                        _whitePasswordField(
                          controller: _passwordController,
                          obscure: _obscure,
                          onToggle: () => setState(() => _obscure = !_obscure),
                          validator: (value) {
                            final v = value ?? "";
                            if (v.isEmpty) return 'Please enter your password';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // 🔹 Sign Up Button
                        Center(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signupUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0CBC8B),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 2,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            child: _loading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Sign up',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🔹 Clickable "Sign In" Text
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmailLoginForm(),
                                ),
                              );
                            },
                            child: Text.rich(
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Sign in",
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
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Helpers
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _whiteField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint ?? '',
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          errorStyle: const TextStyle(color: Color.fromARGB(255, 243, 85, 73)),
          helperText: ' ',
          helperStyle: const TextStyle(height: 0.5),
        ),
      ),
    );
  }

  Widget _whitePasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.black45,
            ),
          ),
          errorStyle: const TextStyle(color: Color.fromARGB(255, 243, 85, 73)),
          helperText: ' ',
          helperStyle: const TextStyle(height: 0.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
