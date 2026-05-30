import 'package:flutter/material.dart';

class PusatBantuanScreen extends StatefulWidget {
  const PusatBantuanScreen({super.key});

  @override
  State<PusatBantuanScreen> createState() => _PusatBantuanScreenState();
}

class _PusatBantuanScreenState extends State<PusatBantuanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Bagaimana cara membuat rangkuman?',
      'answer':
          'Untuk membuat rangkuman, buka halaman "Buat Rangkuman", upload file PDF atau DOCX kamu, atur panjang ringkasan dan jumlah soal kuis, lalu tekan tombol "Buat Rangkuman Sekarang".',
    },
    {
      'question': 'Format file apa yang didukung?',
      'answer':
          'Leksika mendukung file dalam format PDF (.pdf) dan Microsoft Word (.docx). Pastikan ukuran file tidak melebihi batas yang ditentukan.',
    },
    {
      'question': 'Berapa batas ukuran file upload?',
      'answer':
          'Batas ukuran file upload adalah 10 MB per file. Jika file kamu melebihi batas ini, coba kompres terlebih dahulu.',
    },
    {
      'question': 'Kenapa rangkuman saya gagal dibuat?',
      'answer':
          'Rangkuman bisa gagal karena koneksi internet tidak stabil, format file tidak didukung, atau file rusak. Pastikan koneksi kamu stabil dan coba lagi.',
    },
    {
      'question': 'Apakah rangkuman bisa diedit setelah dibuat?',
      'answer':
          'Saat ini rangkuman tidak dapat diedit secara langsung. Kamu bisa membuat rangkuman baru dengan pengaturan berbeda jika hasilnya kurang sesuai.',
    },
    {
      'question': 'Bagaimana cara menggunakan flashcard?',
      'answer':
          'Flashcard akan otomatis dibuat saat kamu mengaktifkan opsi "Buat Flashcard" sebelum membuat rangkuman. Setelah selesai, kamu bisa mengakses kuis dari halaman detail rangkuman.',
    },
  ];

  List<Map<String, String>> get _filteredFaq {
    if (_searchQuery.isEmpty) return _faqItems;
    return _faqItems
        .where((item) =>
            item['question']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FAF2),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildFaqSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Pusat Bantuan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF006947),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ada yang bisa kami\nbantu?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Temukan jawaban dari pertanyaan\nyang sering ditanyakan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB2DECE),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006947).withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF003D2A),
          ),
          decoration: InputDecoration(
            hintText: 'Cari pertanyaan...',
            hintStyle: const TextStyle(
              color: Color(0xFF81B8A5),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF006947),
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF81B8A5),
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    final filtered = _filteredFaq;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERTANYAAN UMUM',
            style: TextStyle(
              color: Color(0xFF2F6555),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      color: Color(0xFF81B8A5),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada hasil untuk "$_searchQuery"',
                      style: const TextStyle(
                        color: Color(0xFF2F6555),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // ✅ FIX: Setiap item FAQ sekarang card terpisah dengan jarak antar item
            Column(
              children: filtered.asMap().entries.map((entry) {
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _ExpandableFaqItem(
                      question: item['question']!,
                      answer: item['answer']!,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ExpandableFaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _ExpandableFaqItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_ExpandableFaqItem> createState() => _ExpandableFaqItemState();
}

class _ExpandableFaqItemState extends State<_ExpandableFaqItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      color: Color(0xFF003D2A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF006947),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FAF2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  color: Color(0xFF2F6555),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}