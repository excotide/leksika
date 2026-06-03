import 'package:flutter/material.dart';

// ============================================================
// PRESENTATION LAYER — Clean Architecture
// File: lib/features/profile/presentation/pages/edit_profile_page.dart
// ============================================================

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controller untuk setiap field input — dipakai kalau nanti
  // dihubungkan ke BLoC/Cubit untuk submit data.
  final _namaController = TextEditingController(text: 'Juli Ayu');
  final _bioController = TextEditingController(text: 'Mahasiswa Teknik Informatika');
  final _emailController = TextEditingController(text: 'julijulay@gmail.com');
  final _institusiController = TextEditingController(text: 'Politeknik Elektronika Negeri Surabaya');
  final _lokasiController = TextEditingController(text: 'Karanggeneng, Lamongan');

  @override
  void dispose() {
    // Selalu dispose controller supaya tidak ada memory leak.
    _namaController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _institusiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background hijau mint sesuai foto
      backgroundColor: const Color(0xFFE3F2E7),

      // ── AppBar ────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF004C31),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Setelan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────
      body: SingleChildScrollView(
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
            const _AvatarPicker(),

            const SizedBox(height: 32),

            // 2. Form fields — setiap field pakai _FormField widget
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
              onPressed: () {           
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET — _AvatarPicker
// Avatar bulat abu-abu dengan badge kamera hijau tua di sudut
// kanan bawah, persis seperti di foto.
// ============================================================
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker();

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(
              Icons.person,
              size: 52,
              color: Color(0xFF9DBBA9),
            ),
          ),
    
          Positioned(
            bottom: 4,
            right: 0,
            child: GestureDetector(
              onTap: () {
                
              },
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
// Field input reusable dengan:
//   - Label kecil hijau tua di atas (NAMA LENGKAP, BIO, dst)
//   - Container putih dengan border hijau transparan + shadow
//   - Prefix icon di kiri
//   - Suffix icon opsional di kanan (untuk email yang locked)
//   - Support readOnly dan multiline
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
// Shadow hijau transparan sesuai foto.
// ============================================================
class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed});

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
        child: const Row(
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