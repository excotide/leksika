import 'package:bloc/bloc.dart';
import 'package:leksika/features/profile/domain/entities/profile_entity.dart';
import 'package:leksika/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:leksika/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:leksika/features/profile/domain/usecases/upload_photo_usecase.dart';
import 'package:leksika/features/profile/presentation/bloc/profile_event.dart';
import 'package:leksika/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.getProfileUsecase,
    required this.updateProfileUsecase,
    required this.uploadPhotoUsecase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadPhoto>(_onUploadPhoto);
  }

  final GetProfileUsecase getProfileUsecase;
  final UpdateProfileUsecase updateProfileUsecase;
  final UploadPhotoUsecase uploadPhotoUsecase;

  ProfileEntity? _lastProfile;

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getProfileUsecase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) {
        _lastProfile = profile;
        emit(ProfileLoaded(profile));
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (_lastProfile != null) emit(ProfileSubmitting(_lastProfile!));
    final result = await updateProfileUsecase(
      name: event.name,
      bio: event.bio,
      institution: event.institution,
      address: event.address,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) {
        _lastProfile = profile;
        emit(ProfileUpdated(profile));
      },
    );
  }

  Future<void> _onUploadPhoto(
    UploadPhoto event,
    Emitter<ProfileState> emit,
  ) async {
    if (_lastProfile != null) emit(ProfileSubmitting(_lastProfile!));
    try {
      final result = await uploadPhotoUsecase(event.filePath);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (profile) {
          _lastProfile = profile;
          emit(ProfilePhotoUpdated(profile));
        },
      );
    } catch (_) {
      // Jaring pengaman: pastikan spinner selalu berhenti
      emit(const ProfileError('Gagal upload foto. Coba lagi.'));
    }
  }
}
