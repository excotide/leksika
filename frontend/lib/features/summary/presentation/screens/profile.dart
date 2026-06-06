import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_event.dart';
import 'package:leksika/features/profile/domain/entities/profile_entity.dart';
import 'package:leksika/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:leksika/features/profile/presentation/bloc/profile_event.dart';
import 'package:leksika/features/profile/presentation/bloc/profile_state.dart';
import 'package:leksika/features/summary/presentation/widgets/bottom_navbar.dart';

class SetelanPage extends StatelessWidget {
  const SetelanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const LoadProfile()),
      child: const _SetelanView(),
    );
  }
}

class _SetelanView extends StatelessWidget {
  const _SetelanView();

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5EE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
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
              child: const Center(
                child: Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: Transform.translate(
        offset: const Offset(0, 8),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/create-rangkuman'),
          backgroundColor: const Color(0xFF006947),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomNavbar(activeIndex: 3),

      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF004C31)),
            );
          }

          if (state is ProfileError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const LoadProfile()),
            );
          }

          final ProfileEntity profile = state is ProfileLoaded
              ? state.profile
              : state is ProfileUpdated
                  ? state.profile
                  : (state as ProfileSubmitting).profile;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                _ProfileHeader(profile: profile),
                const SizedBox(height: 20),

                _StatsCard(
                  totalSummary: profile.totalSummary,
                  totalStreak: profile.totalStreak,
                ),
                const SizedBox(height: 16),

                _InfoCard(
                  icon: Icons.email_outlined,
                  label: 'EMAIL',
                  value: profile.email,
                ),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.school_outlined,
                  label: 'INSTITUSI',
                  value: profile.institution?.isNotEmpty == true
                      ? profile.institution!
                      : '-',
                ),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'LOKASI',
                  value: profile.address?.isNotEmpty == true
                      ? profile.address!
                      : '-',
                ),

                const SizedBox(height: 24),

                _ActionButton(
                  label: 'Edit Profile',
                  icon: Icons.settings_outlined,
                  backgroundColor: const Color(0xFF004C31),
                  textColor: Colors.white,
                  onPressed: () {
                    final bloc = context.read<ProfileBloc>();
                    Navigator.pushNamed(context, '/edit-profil')
                        .then((_) => bloc.add(const LoadProfile()));
                  },
                ),

                const SizedBox(height: 12),

                _ActionButton(
                  label: 'Log Out',
                  backgroundColor: const Color(0xFFD32F2F),
                  textColor: Colors.white,
                  onPressed: () => _confirmLogout(context),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFF004C31), size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF555555)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004C31),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = profile.avatarUrl != null &&
        profile.avatarUrl!.isNotEmpty;

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFFCCCCCC),
          backgroundImage:
              hasAvatar ? NetworkImage(profile.avatarUrl!) : null,
          child: hasAvatar
              ? null
              : const Icon(Icons.person, size: 48, color: Colors.white),
        ),

        const SizedBox(height: 12),

        Text(
          profile.name,
          style: const TextStyle(
            color: Color(0xFF004C31),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          profile.bio?.isNotEmpty == true
              ? profile.bio!
              : 'Belum ada bio',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalSummary,
    required this.totalStreak,
  });

  final int totalSummary;
  final int totalStreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.menu_book_outlined,
                iconColor: const Color(0xFF004C31),
                label: 'MATERI',
                value: '$totalSummary',
              ),
            ),

            const VerticalDivider(
              color: Color(0xFFDDDDDD),
              thickness: 1,
              width: 32,
            ),

            Expanded(
              child: _StatItem(
                icon: Icons.local_fire_department_outlined,
                iconColor: const Color(0xFFFF6B00),
                label: 'STREAK',
                value: '$totalStreak',
                valueColor: const Color(0xFFFF6B00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        Icon(icon, color: iconColor, size: 20),

        const SizedBox(height: 6),

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
          Icon(icon, color: const Color(0xFF004C31), size: 20),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
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
