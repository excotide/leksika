import 'package:flutter/material.dart';

class SyaratKetentuanScreen extends StatefulWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  State<SyaratKetentuanScreen> createState() => _SyaratKetentuanScreenState();
}

class _SyaratKetentuanScreenState extends State<SyaratKetentuanScreen> {
  bool _agreeSyarat = false;
  bool _agreePrivasi = false;

  final List<Map<String, String>> _ketentuanItems = [
    {
      'title': 'Penggunaan Layanan',
      'body':
          'Leksika hanya untuk penggunaan pribadi dan akademik. Dilarang menyebarluaskan konten hasil rangkuman tanpa izin.',
    },
    {
      'title': 'Privasi & Data',
      'body':
          'Data kamu disimpan dengan aman. Kami tidak menjual data pribadi kepada pihak ketiga manapun.',
    },
    {
      'title': 'Konten & Hak Cipta',
      'body':
          'Pastikan dokumen yang diunggah adalah milikmu atau kamu memiliki izin penggunaan yang sah.',
    },
  ];

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
                  const SizedBox(height: 20),
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  _buildKetentuanList(),
                  const SizedBox(height: 20),
                  _buildCheckboxSection(),
                  const SizedBox(height: 24),
                  _buildLanjutkanButton(context),
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
                'Syarat & Ketentuan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF006947),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF006947),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == 1 ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: i == 1 ? 0.9 : 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 34,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Baca sebelum\nmendaftar',
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
              'Pastikan kamu membaca\ndan menyetujui semua\nketentuan berikut',
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

  Widget _buildKetentuanList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _ketentuanItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.circle,
                      color: Color(0xFF006947),
                      size: 10,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            color: Color(0xFF003D2A),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['body']!,
                          style: const TextStyle(
                            color: Color(0xFF2F6555),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCheckboxSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ✅ FIX: Tanpa Container putih, langsung di atas bg hijau muda
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreeSyarat,
                onChanged: (v) => setState(() => _agreeSyarat = v!),
                activeColor: const Color(0xFF006947),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF006947);
                  }
                  return Colors.white;
                }),
                side: const BorderSide(color: Color(0xFF2F6555), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF003D2A),
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(text: 'Saya telah membaca dan menyetujui '),
                      TextSpan(
                        text: 'Syarat & Ketentuan',
                        style: TextStyle(
                          color: Color(0xFF006947),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' Leksika'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreePrivasi,
                onChanged: (v) => setState(() => _agreePrivasi = v!),
                activeColor: const Color(0xFF006947),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF006947);
                  }
                  return Colors.white;
                }),
                side: const BorderSide(color: Color(0xFF2F6555), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF003D2A),
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(text: 'Saya menyetujui '),
                      TextSpan(
                        text: 'Kebijakan Privasi',
                        style: TextStyle(
                          color: Color(0xFF006947),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' dan pemrosesan data saya'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanjutkanButton(BuildContext context) {
    final bool isEnabled = _agreeSyarat && _agreePrivasi;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                Navigator.pop(context, true);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006947),
          disabledBackgroundColor: const Color(0xFF006947).withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: isEnabled ? 6 : 0,
        ),
        child: const Text(
          'Lanjutkan Pendaftaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}