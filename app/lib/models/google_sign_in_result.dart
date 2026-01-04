import '../models/user_model.dart';
import '../models/token_pair.dart';

/// Result from Google Sign-In containing user data and auth tokens
class GoogleSignInResult {
  final UserModel user;
  final TokenPair tokens;

  const GoogleSignInResult({
    required this.user,
    required this.tokens,
  });
}
