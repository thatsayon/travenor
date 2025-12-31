import 'package:flutter/material.dart';
import '../../main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _fullNameController = TextEditingController(text: 'Leonardo Ahmed');
  final _presentAddressController = TextEditingController(text: 'Sylhet, Bangladesh');
  final _phoneController = TextEditingController(text: '01758-000666');
  final _emergencyContactController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  
  // State variables
  String _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;
  String _selectedBloodGroup = 'A+';
  
  // Options
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_selectedDateOfBirth == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select your date of birth')),
                  );
                  return;
                }
                // Save profile logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFFFD6E0),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change picture coming soon')),
                  );
                },
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
