import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  // Sign In with Email and Password
  Future<UserModel> signIn(String email, String password) async {
    try {
      print('📧 Sign-In Request:');
      print('  Email: $email');
      print('  Password: ${'*' * password.length}');

      // Simulate API call - in production, this would be:
      // final response = await _dioClient.dio.post('/auth/signin', data: {
      //   'email': email,
      //   'password': password,
      // });

      // For now, print the data and create a mock user
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      final mockUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@')[0],
        email: email,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('✅ Sign-In Success:');
      print('  User: ${mockUser.toString()}');

      return mockUser;
    } on DioException catch (e) {
      print('❌ Sign-In DioException: ${e.message}');
      throw Exception('Sign-in failed: ${e.message}');
    } catch (e) {
      print('❌ Sign-In Error: $e');
      throw Exception('Sign-in failed: $e');
    }
  }

  // Sign Up with Email and Password
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('📝 Sign-Up Request:');
      print('  Name: $name');
      print('  Email: $email');
      print('  Password: ${'*' * password.length}');

      // Simulate API call - in production, this would be:
      // final response = await _dioClient.dio.post('/auth/signup', data: {
      //   'name': name,
      //   'email': email,
      //   'password': password,
      // });

      // For now, print the data and create a mock user
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      final mockUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('✅ Sign-Up Success:');
      print('  User: ${mockUser.toString()}');

      return mockUser;
    } on DioException catch (e) {
      print('❌ Sign-Up DioException: ${e.message}');
      throw Exception('Sign-up failed: ${e.message}');
    } catch (e) {
      print('❌ Sign-Up Error: $e');
      throw Exception('Sign-up failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      print('👋 Sign-Out Request');
      
      // In production, this would be:
      // await _dioClient.dio.post('/auth/signout');
      
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ Sign-Out Success');
    } catch (e) {
      print('❌ Sign-Out Error: $e');
    }
  }
}
