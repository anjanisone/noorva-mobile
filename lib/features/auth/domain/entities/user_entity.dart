class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? profilePic;
  final String? dob;
  final String? gender;
  final String? occupation;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.profilePic,
    this.dob,
    this.gender,
    this.occupation,
  });
}
