class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profilePicture;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePicture: json['profilePicture'] as String? ?? '',
    );
  }
}
