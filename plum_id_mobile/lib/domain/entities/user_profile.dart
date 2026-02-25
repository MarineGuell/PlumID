import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int id;
  final String username;
  final String email;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [id, username, email];
}
