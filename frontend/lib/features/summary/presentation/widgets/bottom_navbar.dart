import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key, required this.activeIndex});

  final int activeIndex;

  void _smoothPush(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _navItem(
                        context,
                        Icons.home_rounded,
                        'BERANDA',
                        activeIndex == 0,
                        '/home',
                      ),
                    ),
                    Expanded(
                      child: _navItem(
                        context,
                        Icons.description_outlined,
                        'RIWAYAT',
                        activeIndex == 1,
                        '/riwayat',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _navItem(
                        context,
                        Icons.style_outlined,
                        'FLASHCARD',
                        activeIndex == 2,
                        '/flashcard',
                      ),
                    ),
                    Expanded(
                      child: _navItem(
                        context,
                        Icons.person_outline_rounded,
                        'PROFIL',
                        activeIndex == 3,
                        '/profil',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    String route,
  ) {
    return InkWell(
      onTap: () {
        if (!isActive) _smoothPush(context, route);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFB7EDD9) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isActive
                      ? const Color(0xFF064E3B)
                      : const Color(0xFF059669),
                  size: 20,
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? const Color(0xFF064E3B)
                    : const Color(0xFF059669),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
