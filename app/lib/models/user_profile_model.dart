class UserProfileModel {
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? emergencyContact;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? presentAddress;
  final String? emergencyContactRelation;
  final bool isComplete;
  final DateTime? lastUpdated;

  UserProfileModel({
    this.fullName,
    this.phoneNumber,
    this.email,
    this.emergencyContact,
    this.gender,
    this.dateOfBirth,
    this.bloodGroup,
    this.presentAddress,
    this.emergencyContactRelation,
    bool? isComplete,
    this.lastUpdated,
  }) : isComplete = isComplete ?? _checkComplete(
    fullName, 
    phoneNumber, 
    emergencyContact,
    gender,
    dateOfBirth,
    bloodGroup,
    presentAddress,
    emergencyContactRelation,
  );

  // Check if profile is complete (required fields filled)
  static bool _checkComplete(
    String? fullName, 
    String? phoneNumber, 
    String? emergencyContact,
    String? gender,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? presentAddress,
    String? emergencyContactRelation,
  ) {
    return fullName != null && fullName.isNotEmpty &&
        phoneNumber != null && phoneNumber.isNotEmpty &&
        emergencyContact != null && emergencyContact.isNotEmpty &&
        gender != null && gender.isNotEmpty &&
        dateOfBirth != null &&
        bloodGroup != null && bloodGroup.isNotEmpty &&
        presentAddress != null && presentAddress.isNotEmpty &&
        emergencyContactRelation != null && emergencyContactRelation.isNotEmpty;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'emergencyContact': emergencyContact,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bloodGroup': bloodGroup,
      'presentAddress': presentAddress,
      'emergencyContactRelation': emergencyContactRelation,
      'isComplete': isComplete,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Create from JSON (local storage - camelCase)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      emergencyContact: json['emergencyContact'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      bloodGroup: json['bloodGroup'],
      presentAddress: json['presentAddress'],
      emergencyContactRelation: json['emergencyContactRelation'],
      isComplete: json['isComplete'] ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  // Create from API JSON (snake_case field names)
  factory UserProfileModel.fromApiJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['full_name'],
      phoneNumber: json['mobile_number'],
      email: json['email'],
      emergencyContact: json['emergency_contact_number'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      bloodGroup: json['blood_group'],
      presentAddress: json['present_address'],
      emergencyContactRelation: json['emergency_contact_relationship'],
      lastUpdated: DateTime.now(),
    );
  }

  // Copy with method
  UserProfileModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? emergencyContact,
    String? gender,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? presentAddress,
    String? emergencyContactRelation,
    bool? isComplete,
    DateTime? lastUpdated,
  }) {
    return UserProfileModel(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      presentAddress: presentAddress ?? this.presentAddress,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      isComplete: isComplete ?? this.isComplete,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'UserProfileModel(fullName: $fullName, phoneNumber: $phoneNumber, email: $email, isComplete: $isComplete)';
  }
}
