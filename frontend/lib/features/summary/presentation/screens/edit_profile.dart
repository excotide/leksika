import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/core/services/in_app_notification_service.dart';
import 'package:leksika/features/profile/domain/entities/profile_entity.dart';
import 'package:leksika/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:leksika/features/profile/presentation/bloc/profile_event.dart';
import 'package:leksika/features/profile/presentation/bloc/profile_state.dart';

// ============================================================
// PRESENTATION LAYER — Clean Architecture
// File: lib/features/summary/presentation/screens/edit_profile.dart
// ============================================================

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const LoadProfile()),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  // Controller untuk setiap field input.
  final _namaController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _institusiController = TextEditingController();
  final _lokasiController = TextEditingController();

  bool _initialized = false;
  bool _savePressed = false;
  bool _textSaved = false;
  String? _pickedImagePath;

  @override
  void dispose() {
    _namaController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _institusiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  void _populate(ProfileEntity p) {
    _namaController.text = p.name;
    _bioController.text = p.bio ?? '';
    _emailController.text = p.email;
    _institusiController.text = p.institution ?? '';
    _lokasiController.text = p.address ?? '';
    _initialized = true;
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);
      final picked = result?.files.single;
      if (picked == null || !mounted) return;

      final sizeBytes = picked.size;
      if (sizeBytes > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto terlalu besar. Maksimal 5 MB.')),
        );
        return;
      }

      setState(() => _pickedImagePath = picked.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _save() {
    setState(() => _savePressed = true);
    // Update teks profil selalu di-dispatch pertama
    context.read<ProfileBloc>().add(
          UpdateProfile(
            name: _namaController.text.trim(),
            bio: _bioController.text.trim(),
            institution: _institusiController.text.trim(),
            address: _lokasiController.text.trim(),
          ),
        );
    // Jika ada foto baru, queue setelah UpdateProfile (bloc sekuensial)
    if (_pickedImagePath != null) {
      context.read<ProfileBloc>().add(UploadPhoto(_pickedImagePath!));
    }
  }

  ProfileEntity? _profileOf(ProfileState state) {
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileUpdated) return state.profile;
    if (state is ProfilePhotoUpdated) return state.profile;
    if (state is ProfileSubmitting) return state.profile;
    return null;
  }

  void _showFloatingSnackBar(
    String message, {
    Duration? duration,
    bool isError = false,
  }) {
    InAppNotificationService.show(
      title: message,
      icon: isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
      backgroundColor: isError ? const Color(0xFFFF3B30) : Colors.white,
      titleColor: isError ? Colors.white : const Color(0xFF1A1A1A),
      bodyColor: isError ? Colors.white : const Color(0xFF2D6A4F),
      iconBackgroundColor:
          isError ? const Color(0x33FFFFFF) : const Color(0xFFE0F5EC),
      iconColor: isError ? Colors.white : const Color(0xFF1A7A4A),
      closeIconColor: isError ? Colors.white : const Color(0xFF6B7280),
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && !_initialized) {
          _populate(state.profile);
        } else if (state is ProfileUpdated && _savePressed) {
          if (_pickedImagePath != null) {
            // Teks profil tersimpan, masih menunggu upload foto — tandai & tunggu
            setState(() => _textSaved = true);
            _showFloatingSnackBar('Profil tersimpan, mengupload foto...');
          } else {
            // Tidak ada foto baru — selesai
            _showFloatingSnackBar('Profil berhasil diperbarui');
            if (Navigator.canPop(context)) Navigator.pop(context);
          }
        } else if (state is ProfilePhotoUpdated) {
          // Upload foto selesai (langkah terakhir)
          setState(() {
            _pickedImagePath = null;
            _textSaved = false;
          });
          _showFloatingSnackBar('Profil & foto berhasil diperbarui');
          if (Navigator.canPop(context)) Navigator.pop(context);
        } else if (state is ProfileError) {
          setState(() => _savePressed = false);
          if (_textSaved) {
            // Teks profil sudah tersimpan, hanya foto yang gagal — tetap pop
            setState(() {
              _textSaved = false;
              _pickedImagePath = null;
            });
            _showFloatingSnackBar(
              'Profil tersimpan. Foto gagal diupload, coba lagi nanti.',
              duration: const Duration(seconds: 4),
              isError: true,
            );
            if (Navigator.canPop(context)) Navigator.pop(context);
          } else {
            _showFloatingSnackBar(state.message, isError: true);
          }
        }
      },
      builder: (context, state) {
        final isLoadingInitial =
            (state is ProfileLoading || state is ProfileInitial) &&
                !_initialized;
        final isSubmitting = state is ProfileSubmitting;
        final profile = _profileOf(state);
        final avatarUrl = profile?.avatarUrl;

        return Scaffold(
          // Background hijau mint sesuai foto
          backgroundColor: const Color(0xFFE3F2E7),

          // ── AppBar ────────────────────────────────────────────────
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF006947),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Setelan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          body: isLoadingInitial
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF004C31)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 32,
                    left: 20,
                    right: 20,
                    bottom: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Avatar dengan tombol kamera di sudut kanan bawah
                      _AvatarPicker(
                        localImagePath: _pickedImagePath,
                        avatarUrl: avatarUrl,
                        uploading: isSubmitting && _pickedImagePath != null,
                        onTap: _pickImage,
                      ),

                      const SizedBox(height: 32),

                      // 2. Form fields
                      _FormField(
                        label: 'NAMA LENGKAP',
                        controller: _namaController,
                        prefixIcon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        label: 'BIO',
                        controller: _bioController,
                        prefixIcon: Icons.info_outline,
                        minLines: 1,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        label: 'EMAIL',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        // Email field punya ikon kunci di kanan (readonly feel)
                        suffixIcon: Icons.lock_outline,
                        readOnly: true,
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        label: 'INSTITUSI',
                        controller: _institusiController,
                        prefixIcon: Icons.school_outlined,
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        label: 'LOKASI',
                        controller: _lokasiController,
                        prefixIcon: Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 32),

                      // 3. Tombol Simpan Perubahan
                      _SaveButton(
                        loading: isSubmitting,
                        onPressed: isSubmitting ? null : _save,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

// ============================================================
// WIDGET — _AvatarPicker
// Avatar bulat dengan badge kamera hijau tua di sudut kanan bawah.
// Menampilkan foto lokal yang baru dipilih, foto dari server, atau
// placeholder. Saat upload berlangsung tampil indikator loading.
// ============================================================
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.onTap,
    this.localImagePath,
    this.avatarUrl,
    this.uploading = false,
  });

  final VoidCallback onTap;
  final String? localImagePath;
  final String? avatarUrl;
  final bool uploading;

  ImageProvider? get _image {
    if (localImagePath != null) return FileImage(File(localImagePath!));
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return NetworkImage(avatarUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD7E6DC),
              image: image != null
                  ? DecorationImage(image: image, fit: BoxFit.cover)
                  : null,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            // Placeholder ikon orang kalau belum ada foto
            child: uploading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF004C31),
                      strokeWidth: 2.5,
                    ),
                  )
                : image == null
                    ? const Icon(
                        Icons.person,
                        size: 52,
                        color: Color(0xFF9DBBA9),
                      )
                    : null,
          ),

          Positioned(
            bottom: 4,
            right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF004C31),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET — _FormField
// Field input reusable dengan label, container putih, prefix icon,
// suffix icon opsional, support readOnly dan multiline.
// ============================================================
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool readOnly;
  final int minLines;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label di atas field — hijau tua, bold, ukuran kecil
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF004C31),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ),

        // Container field — putih, sudut bulat, shadow halus
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              // Border sangat transparan, hanya hint warna hijau
              color: const Color(0x1A004C31),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            minLines: minLines,
            maxLines: maxLines,
            // Style teks input — hitam gelap, 15px
            style: const TextStyle(
              color: Color(0xFF121E18),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              // Hapus border bawaan TextField supaya pakai border Container
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),

              // Prefix icon — warna hijau tua
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFF004C31),
                size: 20,
              ),

              // Suffix icon opsional (kunci untuk email)
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: const Color(0xFFAAAAAA),
                      size: 16,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET — _SaveButton
// Tombol full-width hijau tua dengan ikon dan label "Simpan Perubahan".
// ============================================================
class _SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const _SaveButton({required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Shadow hijau di bawah tombol — persis seperti di foto
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33006D3D),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004C31),
          foregroundColor: Colors.white,
          elevation: 0, // Shadow sudah di Container, tidak perlu double shadow
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 20, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
