class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isAnonymous;
  final List<String> preferences;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isAnonymous = false,
    this.preferences = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      isAnonymous: json['isAnonymous'] ?? false,
      preferences: List<String>.from(json['preferences'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isAnonymous': isAnonymous,
      'preferences': preferences,
    };
  }
}