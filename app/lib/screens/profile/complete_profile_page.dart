import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../models/tour_model.dart';
import '../../models/user_profile_model.dart';
import '../../services/profile_service.dart';
import '../booking/booking_confirmation_page.dart';

class CompleteProfilePage extends StatefulWidget {
  final TourModel tour;

  const CompleteProfilePage({
    super.key,
    required this.tour,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _profileService = ProfileService();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final profile = await _profileService.getProfile();
    if (profile != null) {
      setState(() {
        _fullNameController.text = profile.fullName ?? '';
        _phoneController.text = profile.phoneNumber ?? '';
        _emailController.text = profile.email ?? '';
        _emergencyContactController.text = profile.emergencyContact ?? '';
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 11) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email';
      }
    }
    return null;
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final profile = UserProfileModel(
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty 
              ? _emailController.text.trim() 
              : null,
          emergencyContact: _emergencyContactController.text.trim(),
          lastUpdated: DateTime.now(),
        );

        await _profileService.saveProfile(profile);

        if (!mounted) return;

        // Navigate to booking confirmation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationPage(
              tour: widget.tour,
              userProfile: profile,
            ),
          ),
        );
      } catch (error) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryTeal,
                    AppTheme.primaryTealDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tour title
                  Text(
                    'Join ${widget.tour.title}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Tour dates
                  Text(
                    widget.tour.durationText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppTheme.backgroundGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
              minHeight: 4,
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Full Name
                      Text(
                        'Full Name *',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: 'As per NID/Passport',
                          filled: true,
                          fillColor: AppTheme.backgroundGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => _validateRequired(value, 'Full name'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Phone Number
                      Text(
                        'Phone Number *',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: '01XXXXXXXXX',
                          filled: true,
                          fillColor: AppTheme.backgroundGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: _validatePhone,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Email (optional)
                      Text(
                        'Email (optional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'your@email.com',
                          filled: true,
                          fillColor: AppTheme.backgroundGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Emergency Contact
                      Text(
                        'Emergency Contact *',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: InputDecoration(
                          hintText: 'Name - Phone',
                          filled: true,
                          fillColor: AppTheme.backgroundGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => _validateRequired(value, 'Emergency contact'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Privacy assurances
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your information is secure and only shared with your tour lead.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 20,
                                  color: AppTheme.success,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Full refund if minimum group size isn\'t met.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 80), // Space for button
                    ],
                  ),
                ),
              ),
            ),

            // Bottom button
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Continue to Payment'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
