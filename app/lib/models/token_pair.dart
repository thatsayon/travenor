/// Response containing access and refresh tokens from backend
class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }
}
