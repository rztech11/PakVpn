import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // optional:
    // scopes: ['email'],
  );

  /// 🔹 Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the login
        print("ℹ️ Google sign-in cancelled by user");
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      print("✅ Google Sign-In Success: ${user?.email}");
      return user;
    } on FirebaseAuthException catch (e, stack) {
      print("🔥 FirebaseAuthException: ${e.code} - ${e.message}");
      print(stack);
      return null;
    } catch (e, stack) {
      print("🔥 UNKNOWN GOOGLE SIGN-IN ERROR: $e");
      print(stack);
      return null;
    }
  }

  /// 🔹 Sign out from Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    print("👋 Signed out from Google and Firebase");
  }
}
