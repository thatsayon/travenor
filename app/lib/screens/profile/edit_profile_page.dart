import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_data_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers - Initialize empty, will be populated from API
  final _fullNameController = TextEditingController();
  final _presentAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  
  // State variables - nullable to avoid showing defaults when data is missing
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String? _selectedBloodGroup;
  String? _profilePicUrl; // Profile picture URL from API
  File? _selectedImageFile; // Newly selected image file for upload
  bool _isLoading = false; // Only show loading on first visit if no cache
  bool _listenersAdded = false; // Track if change listeners are added
  
  // Original values from API for change detection
  String _originalFullName = '';
  String _originalPresentAddress = '';
  String _originalPhone = '';
  String _originalEmergencyContact = '';
  String _originalEmergencyContactRelation = '';
  String? _originalGender;
  DateTime? _originalDateOfBirth;
  String? _originalBloodGroup;
  
  // Options
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Check if we have cached data from provider
    final cachedData = ref.read(profileDataProvider);
    
    if (cachedData.hasValue && cachedData.value!.hasData) {
      // Show cached data immediately (no loading state!)
      _populateFieldsFromData(cachedData.value!.userData!);
    } else {
      // Only show loading if we truly have no data
      setState(() {
        _isLoading = true;
      });
    }

    // Trigger background revalidation to get fresh data
    ref.read(profileDataProvider.notifier).revalidate();
    
    // Listen for when fresh data arrives
    ref.listen(profileDataProvider, (previous, next) {
      if (next.hasValue && next.value!.hasData && mounted) {
        _populateFieldsFromData(next.value!.userData!);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _populateFieldsFromData(Map<String, dynamic> userData) {
    // Debug: Print all fields from API
    print('🔍 API Response Fields:');
    userData.forEach((key, value) {
      print('   $key: $value');
    });
    
    setState(() {
      // Only set values if they exist in the API response, otherwise leave empty
      _fullNameController.text = userData['full_name'] ?? userData['fullName'] ?? '';
      _presentAddressController.text = userData['present_address'] ?? userData['presentAddress'] ?? '';
      _phoneController.text = userData['mobile_number'] ?? userData['phone_number'] ?? userData['phoneNumber'] ?? '';
      _emergencyContactController.text = userData['emergency_contact_number'] ?? userData['emergency_contact'] ?? userData['emergencyContact'] ?? '';
      _emergencyContactRelationController.text = userData['emergency_contact_relationship'] ?? userData['emergency_contact_relation'] ?? userData['emergencyContactRelation'] ?? '';
      
      // Gender
      final gender = userData['gender'];
      print('🔍 Gender from API: $gender');
      if (gender != null) {
        // Convert to title case (Male, Female, Other)
        final genderCapitalized = gender.toString()[0].toUpperCase() + gender.toString().substring(1).toLowerCase();
        if (_genderOptions.contains(genderCapitalized)) {
          _selectedGender = genderCapitalized;
          print('✅ Set gender to: $genderCapitalized');
        }
      }
      
      // Date of Birth
      final dob = userData['date_of_birth'] ?? userData['dateOfBirth'];
      print('🔍 DOB from API: $dob');
      if (dob != null) {
        _selectedDateOfBirth = dob is DateTime ? dob : DateTime.tryParse(dob.toString());
        print('✅ Set DOB to: $_selectedDateOfBirth');
      }
      
      // Blood Group
      final bloodGroup = userData['blood_group'] ?? userData['bloodGroup'];
      print('🔍 Blood group from API: $bloodGroup');
      if (bloodGroup != null && _bloodGroupOptions.contains(bloodGroup)) {
        _selectedBloodGroup = bloodGroup;
        print('✅ Set blood group to: $bloodGroup');
      }
      
      // Profile Picture
      _profilePicUrl = userData['profile_pic'] ?? userData['profilePic'];
      print('🔍 Profile pic URL: $_profilePicUrl');
      
      // Store original values for change detection
      _originalFullName = _fullNameController.text;
      _originalPresentAddress = _presentAddressController.text;
      _originalPhone = _phoneController.text;
      _originalEmergencyContact = _emergencyContactController.text;
      _originalEmergencyContactRelation = _emergencyContactRelationController.text;
      _originalGender = _selectedGender;
      _originalDateOfBirth = _selectedDateOfBirth;
      _originalBloodGroup = _selectedBloodGroup;
    });
    
    // Add listeners to detect changes (only once)
    if (!_listenersAdded) {
      _fullNameController.addListener(_onDataChanged);
      _presentAddressController.addListener(_onDataChanged);
      _phoneController.addListener(_onDataChanged);
      _emergencyContactController.addListener(_onDataChanged);
      _emergencyContactRelationController.addListener(_onDataChanged);
      _listenersAdded = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _presentAddressController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
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
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  // Check if any data has changed from original
  bool _hasChanges() {
    return _fullNameController.text.trim() != _originalFullName ||
           _presentAddressController.text.trim() != _originalPresentAddress ||
           _phoneController.text.trim() != _originalPhone ||
           _emergencyContactController.text.trim() != _originalEmergencyContact ||
           _emergencyContactRelationController.text.trim() != _originalEmergencyContactRelation ||
           _selectedGender != _originalGender ||
           _selectedDateOfBirth != _originalDateOfBirth ||
           _selectedBloodGroup != _originalBloodGroup ||
           _selectedImageFile != null; // Image selected = has changes
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  // Called when text fields change
  void _onDataChanged() {
    setState(() {}); // Rebuild to update button state
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60, // Increased height to prevent button clipping
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8), // Add padding to prevent clipping
            child: TextButton(
              onPressed: (!_isLoading && _hasChanges()) ? () async {
                if (_formKey.currentState!.validate()) {
                  // Validate required selections
                  if (_selectedDateOfBirth == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select your date of birth')),
                    );
                    return;
                  }
                  if (_selectedGender == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select your gender')),
                    );
                    return;
                  }
                  if (_selectedBloodGroup == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select your blood group')),
                    );
                    return;
                  }
                  
                  // Save profile via API
                  setState(() {
                    _isLoading = true;
                  });
                  
                  try {
                    final profileService = ref.read(profileServiceProvider);
                    
                    // Format date as "YYYY-MM-DD"
                    final formattedDate = '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}';
                    
                    final response = await profileService.updateProfileApi(
                      fullName: _fullNameController.text.trim(),
                      gender: _selectedGender!.toLowerCase(), // API expects lowercase
                      dateOfBirth: formattedDate,
                      bloodGroup: _selectedBloodGroup!,
                      presentAddress: _presentAddressController.text.trim(),
                      mobileNumber: _phoneController.text.trim(),
                      emergencyContactNumber: _emergencyContactController.text.trim(),
                      emergencyContactRelationship: _emergencyContactRelationController.text.trim(),
                      profilePicPath: _selectedImageFile?.path, // Include selected image
                    );
                    
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                      
                      if (response.success) {
                        // Clear selected image on success
                        _selectedImageFile = null;
                        
                        // Hard refresh profile data without loading spinner
                        ref.read(profileDataProvider.notifier).refresh();
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response.error ?? 'Failed to update profile')),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              } : null, // Disable if loading or no changes
              child: Text(
                'Done',
                style: TextStyle(
                  color: (!_isLoading && _hasChanges()) ? AppTheme.primaryBlue : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFFD6E0),
                backgroundImage: _selectedImageFile != null
                    ? FileImage(_selectedImageFile!) // Show selected image
                    : (_profilePicUrl != null && _profilePicUrl!.isNotEmpty
                        ? NetworkImage(_profilePicUrl!) // Show API image
                        : null),
                child: (_selectedImageFile == null && (_profilePicUrl == null || _profilePicUrl!.isEmpty))
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: AppTheme.primaryBlue,
                      )
                    : null,
              ),
              
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: _pickImage,
                child: Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form Fields
              
              // 1. Full Name
              _buildFormField(
                label: 'Full Name',
                controller: _fullNameController,
                hint: 'Enter your full name',
              ),
              
              // 2. Gender (Radio Buttons)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _genderOptions.map((gender) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedGender = gender;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ignore: deprecated_member_use
                                Radio<String>(
                                  value: gender,
                                  groupValue: _selectedGender,
                                  activeColor: AppTheme.primaryBlue,
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value!;
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  gender,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // 3. Date of Birth (Native Date Picker)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: AppTheme.textSecondary),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDateOfBirth == null
                                  ? 'Select Date of Birth'
                                  : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                              style: TextStyle(
                                color: _selectedDateOfBirth == null 
                                    ? AppTheme.textLight 
                                    : AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Blood Group (Radio Style Chips)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16), // Matched bottom padding
                child: SizedBox(
                  width: double.infinity, // Ensure full width for alignment
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blood Group',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.start, // Explicit left alignment
                        children: _bloodGroupOptions.map((bg) {
                          final isSelected = _selectedBloodGroup == bg;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedBloodGroup = bg;
                              });
                            },
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
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 5. Present Address
              _buildFormField(
                label: 'Present Address',
                controller: _presentAddressController,
                hint: 'Enter your address',
                maxLines: 2,
              ),

              // 6. Mobile Number
              _buildFormField(
                label: 'Mobile Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefix: '+88',
                hint: '01XXX-XXXXXX',
              ),
              
              // 7. Emergency Contact
              _buildFormField(
                label: 'Emergency Contact',
                controller: _emergencyContactController,
                keyboardType: TextInputType.phone,
                hint: 'Emergency phone number',
              ),
              
              // 8. Emergency Contact Relation
              _buildFormField(
                label: 'Relationship', // Changed label
                controller: _emergencyContactRelationController,
                hint: 'e.g., Father, Mother, Spouse',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? prefix,
    String? hint,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                prefixText: prefix != null ? '$prefix ' : null,
                prefixStyle: TextStyle(
                  color: AppTheme.textPrimary,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
