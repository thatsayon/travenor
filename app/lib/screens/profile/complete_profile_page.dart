import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../models/tour_model.dart';
import '../../models/user_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../booking/booking_confirmation_page.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  final TourModel tour;
  final String bookingId;

  const CompleteProfilePage({
    super.key,
    required this.tour,
    required this.bookingId,
  });

  @override
  ConsumerState<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _presentAddressController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  
  // State variables
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String? _selectedBloodGroup;
  bool _isFetchingProfile = true;
  bool _isSubmitting = false;

  // Options
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final dioClient = ref.read(dioClientProvider);
      final profileService = ProfileService(dioClient);
      
      final response = await profileService.getProfileFromApi();
      
      if (response.success && response.userData != null && mounted) {
        final data = response.userData!;
        setState(() {
          _fullNameController.text = data['full_name'] ?? data['fullName'] ?? '';
          _phoneController.text = data['mobile_number'] ?? data['phone_number'] ?? '';
          _emergencyContactController.text = data['emergency_contact_number'] ?? data['emergency_contact'] ?? '';
          _presentAddressController.text = data['present_address'] ?? '';
          _emergencyContactRelationController.text = data['emergency_contact_relationship'] ?? '';
          
          // Gender
          final gender = data['gender'];
          if (gender != null) {
            final genderCap = gender.toString()[0].toUpperCase() + gender.toString().substring(1).toLowerCase();
            if (_genderOptions.contains(genderCap)) {
              _selectedGender = genderCap;
            }
          }
          
          // DOB
          final dob = data['date_of_birth'];
          if (dob != null) {
            _selectedDateOfBirth = dob is DateTime ? dob : DateTime.tryParse(dob.toString());
          }
          
          // Blood Group
          final bg = data['blood_group'];
          if (bg != null && _bloodGroupOptions.contains(bg)) {
            _selectedBloodGroup = bg;
          }
          
          _isFetchingProfile = false;
        });
      } else {
        if (mounted) setState(() => _isFetchingProfile = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingProfile = false);
      print('Error loading profile: $e');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _presentAddressController.dispose();
    _emergencyContactRelationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      // Validate non-text required fields
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your gender')));
        return;
      }
      if (_selectedDateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your date of birth')));
        return;
      }
      if (_selectedBloodGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your blood group')));
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final dioClient = ref.read(dioClientProvider);
        final profileService = ProfileService(dioClient);

        // Format date as "YYYY-MM-DD"
        final formattedDate = '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}';

        final response = await profileService.updateProfileApi(
          fullName: _fullNameController.text.trim(),
          gender: _selectedGender!.toLowerCase(),
          dateOfBirth: formattedDate,
          bloodGroup: _selectedBloodGroup!,
          presentAddress: _presentAddressController.text.trim(),
          mobileNumber: _phoneController.text.trim(),
          emergencyContactNumber: _emergencyContactController.text.trim(),
          emergencyContactRelationship: _emergencyContactRelationController.text.trim(),
        );

        if (!mounted) return;

        if (response.success && response.userData != null) {
          final profile = UserProfileModel.fromApiJson(response.userData!);
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationPage(
                tour: widget.tour,
                userProfile: profile,
                bookingId: widget.bookingId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // White status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.white,
          ),

          // Main Content
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppTheme.borderGray)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundGray,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Complete Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Form
                Expanded(
                  child: _isFetchingProfile 
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Personal Information'),
                              const SizedBox(height: 16),
                              
                              _buildFormField(
                                label: 'Full Name',
                                controller: _fullNameController,
                                hint: 'As per NID/Passport',
                                textCapitalization: TextCapitalization.words,
                              ),
                              
                              // Gender
                              _buildLabel('Gender'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                children: _genderOptions.map((gender) {
                                  final isSelected = _selectedGender == gender;
                                  return InkWell(
                                    onTap: () => setState(() => _selectedGender = gender),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.primaryBlue : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray,
                                        ),
                                      ),
                                      child: Text(
                                        gender,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),

                              // DOB
                              _buildLabel('Date of Birth'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundGray,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 18, color: AppTheme.textSecondary),
                                      const SizedBox(width: 12),
                                      Text(
                                        _selectedDateOfBirth == null 
                                            ? 'Select Date' 
                                            : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                                        style: TextStyle(
                                          color: _selectedDateOfBirth == null ? AppTheme.textLight : AppTheme.textPrimary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Blood Group
                              _buildLabel('Blood Group'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: _bloodGroupOptions.map((bg) {
                                  final isSelected = _selectedBloodGroup == bg;
                                  return InkWell(
                                    onTap: () => setState(() => _selectedBloodGroup = bg),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.primaryBlue : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray,
                                        ),
                                      ),
                                      child: Text(
                                        bg,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),

                              _buildSectionTitle('Contact Details'),
                              const SizedBox(height: 16),
                              
                              _buildFormField(
                                label: 'Present Address',
                                controller: _presentAddressController,
                                hint: 'Enter your address',
                                maxLines: 2,
                              ),
                              
                              _buildFormField(
                                label: 'Mobile Number',
                                controller: _phoneController,
                                hint: '01XXXXXXXXX',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                              ),

                              const SizedBox(height: 24),
                              _buildSectionTitle('Emergency Contact'),
                              const SizedBox(height: 16),

                              _buildFormField(
                                label: 'Emergency Contact Number',
                                controller: _emergencyContactController,
                                hint: 'Phone number',
                                keyboardType: TextInputType.phone,
                              ),
                              
                              _buildFormField(
                                label: 'Relationship',
                                controller: _emergencyContactRelationController,
                                hint: 'e.g. Father, Mother, Spouse',
                                textCapitalization: TextCapitalization.words,
                              ),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                ),

                // Bottom Button
                Container(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppTheme.borderGray)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isFetchingProfile || _isSubmitting) ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                            )
                          : const Text(
                              'Continue to Booking',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
              filled: true,
              fillColor: AppTheme.backgroundGray,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              if (keyboardType == TextInputType.phone && value.length < 11) {
                return 'Enter valid phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
