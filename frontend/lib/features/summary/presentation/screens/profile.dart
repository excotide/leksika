import 'package:flutter/material.dart';
import 'package:leksika/features/summary/presentation/widgets/bottom_navbar.dart';

class SetelanPage extends StatelessWidget {
  const SetelanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold adalah root widget halaman ini.
    // backgroundColor 
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF004C31),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-rangkuman'),
        backgroundColor: const Color(0xFF006947),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomNavbar(activeIndex: 3),

      // ── Body ─────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 20),

            // 2. Stats Card (Materi & Streak)
            const _StatsCard(),
            const SizedBox(height: 16),

            // 3. Info Cards (Email, Institusi, Lokasi)
            const _InfoCard(
              icon: Icons.email_outlined,
              label: 'EMAIL',
              value: 'julijulay@gmail.com',
            ),
            const SizedBox(height: 10),
            const _InfoCard(
              icon: Icons.school_outlined,
              label: 'INSTITUSI',
              value: 'Politeknik Elektronika Negeri Surabaya',
            ),
            const SizedBox(height: 10),
            const _InfoCard(
              icon: Icons.location_on_outlined,
              label: 'LOKASI',
              value: 'Karanggeneng, Lamongan',
            ),

            const SizedBox(height: 24),

            // 4. Tombol Edit Profile 
            _ActionButton(
              label: 'Edit Profile',
              icon: Icons.settings_outlined,
              backgroundColor: const Color(0xFF004C31),
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profil');
              },
            ),

            const SizedBox(height: 12),

            // 5. Tombol Log Out
            _ActionButton(
              label: 'Log Out',
              backgroundColor: const Color(0xFFD32F2F),
              textColor: Colors.white,
              onPressed: () {
                
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET — _ProfileHeader
// Menampilkan foto profil bulat, nama besar, dan bio di bawahnya.
// ============================================================
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CircleAvatar: foto profil pengguna.
        // radius: 48 → diameter 96px, sesuai foto.
        CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFFCCCCCC),
          // Ganti dengan NetworkImage/AssetImage sesuai data user.
          child: const Icon(Icons.person, size: 48, color: Colors.white),
        ),

        const SizedBox(height: 12),

        // Nama pengguna — bold, hijau tua, uppercase-feel lewat letterSpacing.
        const Text(
          'JULI AYU',
          style: TextStyle(
            color: Color(0xFF004C31),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 4),

        // Bio / deskripsi singkat — abu-abu gelap, ukuran lebih kecil.
        const Text(
          'Mahasiswa Teknik Informatika',
          style: TextStyle(
            color: Color(0xFF555555),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET — _StatsCard
// Kartu putih berisi dua kolom statistik: Materi & Streak.
// Dipisahkan oleh garis vertikal tipis di tengah.
// ============================================================
class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Kartu putih dengan sudut membulat dan shadow halus.
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      child: IntrinsicHeight(
        // IntrinsicHeight memastikan Divider vertikal setinggi Row-nya.
        child: Row(
          children: [
            // Kolom kiri: Materi
            const Expanded(
              child: _StatItem(
                icon: Icons.menu_book_outlined,
                iconColor: Color(0xFF004C31),
                label: 'MATERI',
                value: '10',
              ),
            ),

            // Garis pemisah vertikal
            const VerticalDivider(
              color: Color(0xFFDDDDDD),
              thickness: 1,
              width: 32,
            ),

            // Kolom kanan: Streak (ikon api, warna oranye)
            const Expanded(
              child: _StatItem(
                icon: Icons.local_fire_department_outlined,
                iconColor: Color(0xFFFF6B00),
                label: 'STREAK',
                value: '7',
                valueColor: Color(0xFFFF6B00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET — _StatItem
// Satu kolom statistik: ikon, label teks kecil, angka besar.
// ============================================================
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF121E18),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ikon di atas (warna berbeda per stat)
        Icon(icon, color: iconColor, size: 20),

        const SizedBox(height: 6),

        // Label kecil uppercase (MATERI / STREAK)
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 2),

        // Angka besar — nilai statistik
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET — _InfoCard
// Kartu putih satu baris: ikon kiri, label atas + nilai bawah.
// Dipakai untuk Email, Institusi, dan Lokasi.
// ============================================================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1A004C31), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ikon di sebelah kiri, warna hijau tua.
          Icon(icon, color: const Color(0xFF004C31), size: 20),

          const SizedBox(width: 12),

          // Kolom teks: label kecil hijau tua di atas, nilai di bawah.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label field — kecil, bold, hijau tua
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF004C31),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 2),

                // Nilai — teks utama, hitam gelap
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF121E18),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET — _ActionButton
// Tombol full-width generik: bisa untuk Edit Profile maupun Log Out.
// Menerima warna background, warna teks, label, dan ikon opsional.
// ============================================================
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,

        // Style tombol: background color sesuai parameter, sudut membulat.
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Konten tombol: ikon (opsional) + label
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}