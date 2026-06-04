import 'package:equatable/equatable.dart';
import 'package:leksika/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

/// Dipakai saat update / upload foto sedang berlangsung
/// (tetap membawa profil lama agar UI tidak kosong).
class ProfileSubmitting extends ProfileState {
  const ProfileSubmitting(this.profile);

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

/// Sukses update profil atau upload foto.
class ProfileUpdated extends ProfileState {
  const ProfileUpdated(this.profile);

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
