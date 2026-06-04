import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.name,
    required this.email,
    this.bio,
    this.institution,
    this.address,
    this.avatarUrl,
    this.totalSummary = 0,
    this.totalStreak = 0,
  });

  final String name;
  final String email;
  final String? bio;
  final String? institution;
  final String? address;
  final String? avatarUrl;
  final int totalSummary;
  final int totalStreak;

  @override
  List<Object?> get props => [
        name,
        email,
        bio,
        institution,
        address,
        avatarUrl,
        totalSummary,
        totalStreak,
      ];
}
