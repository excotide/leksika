import 'package:leksika/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.email,
    super.bio,
    super.institution,
    super.address,
    super.avatarUrl,
    super.totalSummary,
    super.totalStreak,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] != null
        ? json['data'] as Map<String, dynamic>
        : json;
    return ProfileModel(
      name: (data['name'] as String?) ?? 'User',
      email: (data['email'] as String?) ?? '',
      bio: data['bio'] as String?,
      institution: data['institution'] as String?,
      address: data['address'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      totalSummary: (data['total_summary'] as num?)?.toInt() ?? 0,
      totalStreak: (data['total_streak'] as num?)?.toInt() ?? 0,
    );
  }
}
