import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: '372278748604-nt92s4inhiged16m5tpjc8vslvgt4hoj.apps.googleusercontent.com',
  );

  static Future<String?> getIdToken() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      return null;
    }
  }
}