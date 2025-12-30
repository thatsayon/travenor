import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../../models/auth_state.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  // Mock Google Sign-in for testing (works on desktop)
  Future<void> _mockGoogleSignIn(WidgetRef ref) async {
    // Create a mock user
    final mockUser = UserModel(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Test User',
      email: 'testuser@travenor.com',
      photoUrl: 'https://ui-avatars.com/api/?name=Test+User&background=0F766E&color=fff',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Store user data locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', '''
    {
      "id": "${mockUser.id}",
      "name": "${mockUser.name}",
      "email": "${mockUser.email}",
      "photoUrl": "${mockUser.photoUrl}",
      "token": "${mockUser.token}"
    }
    ''');
    await prefs.setString('auth_token', mockUser.token!);
    await prefs.setBool('is_authenticated', true);

    // Update auth state  
    ref.read(authProvider.notifier).state = AuthState(
      status: AuthStatus.authenticated,
      user: mockUser,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Navigate to home on successful authentication
    ref.listen<AuthState>(authProvider, (AuthState? previous, AuthState next) {
      if (next.hasError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      if (next.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Welcome to Travenor',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Join curated group tours.\nPay small, travel big.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Mock Google Sign-in button (works on all platforms)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          await _mockGoogleSignIn(ref);
                        },
                  icon: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Image.network(
                          'https://www.google.com/favicon.ico',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.login, color: Colors.white);
                          },
                        ),
                  label: Text(
                    authState.isLoading ? 'Signing in...' : 'Continue with Google',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.textPrimary,
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    side: BorderSide(color: AppTheme.borderGray),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info text for desktop
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppTheme.primaryTeal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using demo mode for testing on desktop',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Terms and privacy
              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
