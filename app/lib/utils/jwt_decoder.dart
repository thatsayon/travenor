import 'dart:convert';

/// Utility class for decoding JWT tokens
class JwtDecoder {
  /// Decode a JWT token and return the payload as a Map
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      print('🔍 Decoding JWT token...');
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid JWT format - expected 3 parts, got ${parts.length}');
        return null;
      }

      // Get the payload (second part)
      final payload = parts[1];
      print('📦 Payload part: ${payload.substring(0, 50)}...');
      
      // JWT uses base64url encoding, which is slightly different from standard base64
      // We need to handle padding
      String normalized = base64.normalize(payload);
      
      // Decode from base64
      final decoded = utf8.decode(base64.decode(normalized));
      print('📜 Decoded payload: $decoded');
      
      // Parse JSON
      final result = json.decode(decoded) as Map<String, dynamic>;
      print('✅ JWT decoded successfully: ${result.keys.join(', ')}');
      return result;
    } catch (e) {
      print('❌ Failed to decode JWT: $e');
      return null;
    }
  }

  /// Extract user information from JWT claims
  static Map<String, dynamic>? extractUserInfo(String token) {
    final claims = decodeToken(token);
    if (claims == null) {
      print('❌ No claims found in token');
      return null;
    }

    final userInfo = {
      'id': claims['user_id'],
      'email': claims['email'],
      'name': claims['full_name'] ?? claims['username'] ?? claims['email']?.split('@')[0],
      'photoUrl': claims['profile_pic'],
      'username': claims['username'],
    };
    
    print('👤 Extracted user info: $userInfo');
    return userInfo;
  }
}
