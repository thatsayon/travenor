class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? token;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'token': token,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, photoUrl: $photoUrl, token: $token)';
  }
}
