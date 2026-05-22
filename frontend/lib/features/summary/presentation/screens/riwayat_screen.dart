import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_event.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_state.dart';
import 'package:leksika/features/summary/presentation/widgets/bottom_navbar.dart';
import 'package:leksika/shared/widgets/error_widget.dart';
import 'package:leksika/shared/widgets/loading_widget.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  RiwayatScreenState createState() => RiwayatScreenState();
}

class RiwayatScreenState extends State<RiwayatScreen> {
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
        bottomNavigationBar: const BottomNavbar(activeIndex: 1),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF006947),
                onRefresh: () async {
                  context.read<SummaryBloc>().add(const FetchDocumentsRequested());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _buildHistorySection(),
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) {
        if (state is SummaryLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: LoadingWidget(message: 'Memuat riwayat...'),
          );
        }
        
        if (state is SummaryFailure) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ErrorView(
              message: state.message,
              onRetry: () => context.read<SummaryBloc>().add(const FetchDocumentsRequested()),
            ),
          );
        }
        
        if (state is SummaryListLoaded) {
          if (state.documents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  children: [
                    Icon(Icons.history_edu_rounded, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada riwayat rangkuman.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return Column(
            children: state.documents
                .map((doc) => _buildHistoryCardFromDocument(context, doc))
                .toList(),
          );
        }
        
        return const SizedBox.shrink();
      },
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
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Riwayat Rangkuman',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none_outlined, color: Color(0xFF006947), size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCardFromDocument(BuildContext context, DocumentEntity doc) {
    final title = doc.title.isEmpty ? 'Untitled Document' : doc.title;
    final desc = doc.summary;
    final time = _formatDate(doc.createdAt);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: {
            'title': title,
            'pageCount': 'Ringkasan',
            'contents': [
              {'subTitle': 'Hasil Rangkuman', 'body': desc},
            ],
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF5EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_outlined,
                      size: 18, color: Color(0xFF006947)),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF003D2A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              maxLines: 3, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF2F6555),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFDDEDE8)),
            ),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFF2F6555)),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(color: Color(0xFF2F6555), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Baru saja';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}