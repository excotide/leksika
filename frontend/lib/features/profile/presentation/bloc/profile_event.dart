import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  const UpdateProfile({
    this.name,
    this.bio,
    this.institution,
    this.address,
  });

  final String? name;
  final String? bio;
  final String? institution;
  final String? address;

  @override
  List<Object?> get props => [name, bio, institution, address];
}

class UploadPhoto extends ProfileEvent {
  const UploadPhoto(this.filePath);

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}
