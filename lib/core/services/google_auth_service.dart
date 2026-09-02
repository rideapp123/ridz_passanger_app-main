import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  factory GoogleAuthService() => _instance ??= GoogleAuthService._();

  GoogleAuthService._();
  static GoogleAuthService? _instance;
  late GoogleSignIn _googleSignIn;

  void initialize() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
    );
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await account.authentication;

        var idToken = googleSignInAuthentication.idToken;
        return idToken;
      }

      return null;
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
