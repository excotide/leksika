import 'dart:async';
import 'package:flutter/material.dart';

class RangkumanLoadingOverlay extends StatefulWidget {
  const RangkumanLoadingOverlay({super.key});

  @override
  State<RangkumanLoadingOverlay> createState() => _RangkumanLoadingOverlayState();
}

class _RangkumanLoadingOverlayState extends State<RangkumanLoadingOverlay> {
  final List<String> _labels = [
    'Menganalisis teks...',
    'Mengidentifikasi poin utama...',
    'Menyusun struktur rangkuman...',
    'Memfinalisasi rangkuman...',
  ];
  final List<double> _percentages = [0.2, 0.5, 0.75, 0.95];

  int _currentStep = 0;
  bool _showCancel = false;
  Timer? _stepTimer;
  Timer? _cancelTimer;

  @override
  void initState() {
    super.initState();
    _stepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentStep < _labels.length - 1) {
        setState(() => _currentStep++);
      } else {
        timer.cancel();
      }
    });
    _cancelTimer = Timer(const Duration(minutes: 5), () {
      if (mounted) {
        setState(() => _showCancel = true);
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _cancelTimer?.cancel();
    super.dispose();
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        body: AbsorbPointer(
          absorbing: !_showCancel,
          child: Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showCancel)
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: _cancel,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                  const CircularProgressIndicator(
                    color: Color(0xFF639922),
                    backgroundColor: Color(0xFFC0DD97),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _showCancel
                        ? 'Proses memakan waktu lebih lama dari biasanya...'
                        : _labels[_currentStep],
                    style: TextStyle(
                      fontSize: 14,
                      color: _showCancel
                          ? Colors.orange
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Membuat rangkuman',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(_percentages[_currentStep] * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: _percentages[_currentStep],
                      minHeight: 6,
                      backgroundColor: const Color(0xFFC0DD97),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF639922)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}