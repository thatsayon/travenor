import 'package:flutter/material.dart';
import '../../main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Leonardo');
  final _lastNameController = TextEditingController(text: 'Ahmed');
  final _locationController = TextEditingController(text: 'Sylhet Bangladesh');
  final _phoneController = TextEditingController(text: '01758-000666');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                // Save profile
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: AppTheme.primaryTeal,
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
                    radius: 60,
                    backgroundColor: const Color(0xFFFFD6E0),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Leonardo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              
              const SizedBox(height: 4),
              
              TextButton(
                onPressed: () {
                  // Change profile picture
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change picture coming soon')),
                  );
                },
                child: Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Form Fields
              _buildFormField(
                label: 'First Name',
                controller: _firstNameController,
              ),
              
              _buildFormField(
                label: 'Last Name',
                controller: _lastNameController,
              ),
              
              _buildFormField(
                label: 'Location',
                controller: _locationController,
              ),
              
              _buildFormField(
                label: 'Mobile Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefix: '+88',
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
                suffixIcon: Icon(
                  Icons.check,
                  color: AppTheme.primaryTeal,
                  size: 20,
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
