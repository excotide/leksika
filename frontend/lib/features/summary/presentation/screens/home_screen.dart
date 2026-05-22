import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_event.dart'; 
import 'package:leksika/features/auth/presentation/bloc/auth_state.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_event.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_state.dart';
import 'package:leksika/features/summary/presentation/widgets/bottom_navbar.dart';
import 'package:leksika/shared/widgets/error_widget.dart';
import 'package:leksika/shared/widgets/loading_widget.dart';
import 'package:leksika/core/di/injection_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  
  // Logika Menghitung Streak Harian berturut-turut
  int _calculateDailyStreak(List<DocumentEntity> documents) {
    if (documents.isEmpty) return 0;

    // Ambil semua tanggal unik saat user merangkum (hanya tanggal, tanpa jam)
    final dates = documents
        .where((doc) => doc.createdAt != null)
        .map((doc) => DateTime(doc.createdAt!.year, doc.createdAt!.month, doc.createdAt!.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Urutkan dari yang terbaru

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Jika tidak ada aktivitas hari ini DAN kemarin, streak putus (0)
    if (!dates.contains(today) && !dates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    // Mulai pengecekan dari hari ini (jika ada) atau kemarin
    DateTime checkDate = dates.contains(today) ? today : yesterday;

    // Loop mundur untuk mengecek kesinambungan hari
    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SummaryBloc>()..add(const FetchDocumentsRequested()),
      child: Scaffold(
        backgroundColor: const Color(0xFFE8FAF2),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/create-rangkuman'),
          backgroundColor: const Color(0xFF006947),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const BottomNavbar(activeIndex: 0),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingSection(),
                _buildMainBanner(),
                _buildHistoryHeader(),
                _buildHistorySection(),
                _buildDailyTarget(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'LEKSIKA',
            style: TextStyle(
              color: Color(0xFF003D2A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              _buildTopIcon(Icons.notifications_none_outlined),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showLogoutConfirmation(context),
                child: _buildTopIcon(
                  Icons.logout_rounded,
                  bgColor: const Color(0xFFFFEBEB),
                  iconColor: const Color(0xFFC70000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, {Color bgColor = Colors.white, Color iconColor = const Color(0xFF006947)}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF006947), Color(0xFF00A86B)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELAMAT DATANG KEMBALI,',
            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
          ),
          const SizedBox(height: 2),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String name = 'Pelajar';
              if (state is Authenticated) name = state.user.name;
              return Text(
                name.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildStreakBadge(),
        ],
      ),
    );
  }

  Widget _buildStreakBadge() {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) {
        int dayStreak = 0;
        bool isAlreadyActiveToday = false;

        if (state is SummaryListLoaded) {
          dayStreak = _calculateDailyStreak(state.documents);
          
          // Cek apakah hari ini sudah ada aktivitas
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          isAlreadyActiveToday = state.documents.any((doc) => 
            doc.createdAt != null && 
            DateTime(doc.createdAt!.year, doc.createdAt!.month, doc.createdAt!.day) == today
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  // Berwarna orange menyala jika user sudah aktif hari ini
                  color: isAlreadyActiveToday ? const Color(0xFFF5A623) : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('STREAK HARIAN', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                    dayStreak > 0 ? '$dayStreak Hari Berturut-turut!' : 'Mulai streak harimu!',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistorySection() {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) {
        if (state is SummaryLoading) return const LoadingWidget(message: 'Memuat data...');
        if (state is SummaryFailure) return ErrorView(message: state.message, onRetry: () => context.read<SummaryBloc>().add(const FetchDocumentsRequested()));
        if (state is SummaryListLoaded) {
          if (state.documents.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('Belum ada riwayat rangkuman.'));
          return Column(children: state.documents.take(2).map((doc) => _buildHistoryCardFromDocument(doc)).toList());
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Riwayat Rangkuman', style: TextStyle(color: Color(0xFF003D2A), fontSize: 19, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/riwayat'),
            child: const Text('Lihat semua →', style: TextStyle(color: Color(0xFF006947), fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCardFromDocument(DocumentEntity doc) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: {
        'title': doc.title.isEmpty ? 'Untitled' : doc.title,
        'pageCount': 'Ringkasan',
        'contents': [{'subTitle': 'Ringkasan', 'body': doc.summary}],
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconBadge(Icons.description_outlined),
                _buildCategoryBadge('RINGKASAN'),
              ],
            ),
            const SizedBox(height: 12),
            Text(doc.title.isEmpty ? 'Untitled' : doc.title, style: const TextStyle(color: Color(0xFF003D2A), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(doc.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF2F6555), fontSize: 13)),
            const Divider(height: 24, color: Color(0xFFDDEDE8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFooterInfo(Icons.access_time_rounded, _formatDate(doc.createdAt)),
                _buildFooterInfo(Icons.description_outlined, 'Ringkasan'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFDFF5EC), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: const Color(0xFF006947)));
  Widget _buildCategoryBadge(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF6AEFB8), borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(color: Color(0xFF004D33), fontSize: 10, fontWeight: FontWeight.bold)));
  Widget _buildFooterInfo(IconData icon, String text) => Row(children: [Icon(icon, size: 13, color: const Color(0xFF2F6555)), const SizedBox(width: 4), Text(text, style: const TextStyle(color: Color(0xFF2F6555), fontSize: 12))]);

  String _formatDate(DateTime? date) => date == null ? 'Baru saja' : '${date.day}/${date.month}/${date.year}';

  Widget _buildDailyTarget() {
    return Container(
      width: double.infinity, margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(color: const Color(0xFFDFF5EC), borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        child: Column(
          children: [
            const Text('Target Hari Ini', style: TextStyle(color: Color(0xFF006947), fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Kamu hampir mencapai target belajar harianmu! Buat rangkuman lagi untuk mempertahankan streak.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF2F6555), fontSize: 13, height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/create-rangkuman'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Lanjut Belajar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006947), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
            ),
          ],
        ),
      ),
    );
  }
}