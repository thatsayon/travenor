import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      
      // Create user model from Google account data
      final user = UserModel(
        id: account.id,
        name: account.displayName ?? '',
        email: account.email,
        photoUrl: account.photoUrl,
        token: auth.idToken,
      );

      print('✅ Google Sign-In Success:');
      print('  Name: ${user.name}');
      print('  Email: ${user.email}');
      print('  Photo URL: ${user.photoUrl}');
      print('  ID Token: ${auth.idToken?.substring(0, 20)}...');
      print('  Access Token: ${auth.accessToken?.substring(0, 20)}...');

      return user;
    } catch (error) {
      print('❌ Google Sign-In Error: $error');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Google Sign-Out Success');
    } catch (error) {
      print('❌ Google Sign-Out Error: $error');
    }
  }

  // Check if already signed in
  Future<UserModel?> getCurrentUser() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      
      return UserModel(
        id: account.id,
        name: account.displayName ?? '',
        email: account.email,
        photoUrl: account.photoUrl,
        token: auth.idToken,
      );
    } catch (error) {
      print('❌ Get Current User Error: $error');
      return null;
    }
  }
}
