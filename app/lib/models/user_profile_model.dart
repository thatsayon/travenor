class UserProfileModel {
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? emergencyContact;
  final bool isComplete;
  final DateTime? lastUpdated;

  UserProfileModel({
    this.fullName,
    this.phoneNumber,
    this.email,
    this.emergencyContact,
    bool? isComplete,
    this.lastUpdated,
  }) : isComplete = isComplete ?? _checkComplete(fullName, phoneNumber, emergencyContact);

  // Check if profile is complete (required fields filled)
  static bool _checkComplete(String? fullName, String? phoneNumber, String? emergencyContact) {
    return fullName != null &&
        fullName.isNotEmpty &&
        phoneNumber != null &&
        phoneNumber.isNotEmpty &&
        emergencyContact != null &&
        emergencyContact.isNotEmpty;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'emergencyContact': emergencyContact,
      'isComplete': isComplete,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      emergencyContact: json['emergencyContact'],
      isComplete: json['isComplete'] ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  // Copy with method
  UserProfileModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? emergencyContact,
    bool? isComplete,
    DateTime? lastUpdated,
  }) {
    return UserProfileModel(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isComplete: isComplete ?? this.isComplete,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'UserProfileModel(fullName: $fullName, phoneNumber: $phoneNumber, email: $email, isComplete: $isComplete)';
  }
}
