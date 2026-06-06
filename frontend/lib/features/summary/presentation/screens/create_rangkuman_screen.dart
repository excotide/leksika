import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/core/services/in_app_notification_service.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_event.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_state.dart';
import 'package:leksika/features/summary/presentation/screens/pusat_bantuan_screen.dart';
import 'package:leksika/features/summary/presentation/widgets/rangkuman_loading_overlay.dart';

class CreateRangkumanScreen extends StatefulWidget {
  const CreateRangkumanScreen({super.key});
  @override
  CreateRangkumanScreenState createState() => CreateRangkumanScreenState();
}

class CreateRangkumanScreenState extends State<CreateRangkumanScreen> {
  String _selectedPanjang = 'Sedang (5-7 Paragraf)';
  String _selectedSoal = '10 Soal';
  bool _buatFlashcard = true;
  File? _selectedFile;
  bool _isLoadingVisible = false;

  final List<String> _panjangOptions = [
    'Singkat (3-4 Paragraf)',
    'Sedang (5-7 Paragraf)',
    'Panjang (8-10 Paragraf)',
  ];

  final List<String> _soalOptions = ['5 Soal', '10 Soal', '15 Soal'];

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SummaryBloc>(),
      child: BlocListener<SummaryBloc, SummaryState>(
        listener: (context, state) {
          if (state is SummaryLoading && !_isLoadingVisible) {
            _isLoadingVisible = true;
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, _, _) => const RangkumanLoadingOverlay(),
              ),
            );
          } else if (state is SummaryDetailLoaded) {
            if (_isLoadingVisible) {
              _isLoadingVisible = false;
              if (Navigator.canPop(context)) Navigator.pop(context);
            }
            Navigator.pushReplacementNamed(
              context,
              '/detail',
              arguments: {
                'title': state.document.title.isEmpty
                    ? 'Hasil Rangkuman'
                    : state.document.title,
                'pageCount': 'Proses AI',
                'contents': [
                  {'subTitle': 'Ringkasan', 'body': state.document.summary},
                ],
                'document': state.document,
              },
            );
          } else if (state is SummaryFailure) {
            if (_isLoadingVisible) {
              _isLoadingVisible = false;
              if (Navigator.canPop(context)) Navigator.pop(context);
            }
            InAppNotificationService.show(
              title: 'Gagal membuat rangkuman',
              body: state.message,
              icon: Icons.error_outline_rounded,
              backgroundColor: const Color(0xFFFF3B30),
              titleColor: Colors.white,
              bodyColor: Colors.white,
              iconBackgroundColor: Color(0x33FFFFFF),
              iconColor: Colors.white,
              closeIconColor: Colors.white,
              bodyMaxLines: 5,
              duration: const Duration(seconds: 6),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFE8FAF2),
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildUploadArea(),
                      const SizedBox(height: 28),
                      _buildSettingsTitle(),
                      const SizedBox(height: 14),
                      _buildFlashcardSwitch(),
                      const SizedBox(height: 16),
                      _buildDropdownLabel('PANJANG RINGKASAN'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildDropdown(
                          value: _selectedPanjang,
                          items: _panjangOptions,
                          onChanged: (val) =>
                              setState(() => _selectedPanjang = val!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownLabel('JUMLAH SOAL KUIS'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Opacity(
                          opacity: _buatFlashcard ? 1.0 : 0.4,
                          child: IgnorePointer(
                            ignoring: !_buatFlashcard,
                            child: _buildDropdown(
                              value: _selectedSoal,
                              items: _soalOptions,
                              onChanged: (val) =>
                                  setState(() => _selectedSoal = val!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 16),
                      _buildHelpCenter(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
              const Text(
                'Buat Rangkuman',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifikasi'),
                child: Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _pickFile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(
            border: DashedBorder.fromBorderSide(
              dashLength: 12,
              side: const BorderSide(color: Color(0xFF81B8A5), width: 1.5),
            ),
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.5),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF69F6B8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_outlined,
                  size: 32,
                  color: Color(0xFF006947),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFile == null
                    ? 'Tap untuk Upload File'
                    : 'File Siap Diolah',
                style: const TextStyle(
                  color: Color(0xFF00362A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedFile == null
                    ? 'Dukung PDF, DOCX, atau Gambar'
                    : _selectedFile!.path.split('/').last,
                style: const TextStyle(color: Color(0xFF2F6555), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: const [
          Icon(Icons.tune, color: Color(0xFF2F6555), size: 18),
          SizedBox(width: 6),
          Text(
            'Pengaturan Rangkuman',
            style: TextStyle(
              color: Color(0xFF00362A),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FAF2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.style_outlined,
                color: Color(0xFF006947),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Buat Flashcard',
                    style: TextStyle(
                      color: Color(0xFF00362A),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Otomatis buat kuis',
                    style: TextStyle(color: Color(0xFF2F6555), fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch(
              value: _buatFlashcard,
              onChanged: (val) => setState(() => _buatFlashcard = val),
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF006947),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2F6555),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) {
        bool isLoading = state is SummaryLoading;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (_selectedFile == null) {
                      InAppNotificationService.show(
                        title: 'Pilih file terlebih dahulu',
                        body: 'Unggah dokumen sebelum membuat rangkuman.',
                        icon: Icons.error_outline_rounded,
                        backgroundColor: const Color(0xFFFF3B30),
                        titleColor: Colors.white,
                        bodyColor: Colors.white,
                        iconBackgroundColor: Color(0x33FFFFFF),
                        iconColor: Colors.white,
                        closeIconColor: Colors.white,
                      );
                      return;
                    }
                    context.read<SummaryBloc>().add(
                      UploadDocumentRequested(
                        filePath: _selectedFile!.path,
                        length: _selectedPanjang,
                        makeQuiz: _buatFlashcard ? 'Ya' : 'Tidak',
                        quizCount: _selectedSoal,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006947),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              elevation: 6,
            ),
            child: const Text(
              'Buat Rangkuman Sekarang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // ✅ FIX: context sekarang diteruskan sebagai parameter agar Navigator bisa digunakan
  Widget _buildHelpCenter(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PusatBantuanScreen(),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.help_outline, color: Color(0xFF2F6555), size: 14),
            SizedBox(width: 4),
            Text(
              'Need Help?',
              style: TextStyle(
                color: Color(0xFF2F6555),
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
