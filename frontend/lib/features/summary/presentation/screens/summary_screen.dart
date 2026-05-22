import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_event.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_state.dart';
import 'package:leksika/shared/widgets/error_widget.dart';
import 'package:leksika/shared/widgets/loading_widget.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SummaryBloc>()..add(const FetchDocumentsRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Summaries')),
        body: BlocBuilder<SummaryBloc, SummaryState>(
          builder: (context, state) {
            if (state is SummaryLoading) {
              return const LoadingWidget(message: 'Loading summaries...');
            }
            if (state is SummaryFailure) {
              return ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<SummaryBloc>()
                    .add(const FetchDocumentsRequested()),
              );
            }
            if (state is SummaryListLoaded) {
              if (state.documents.isEmpty) {
                return const Center(child: Text('No summaries yet.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final doc = state.documents[index];
                  return ListTile(
                    title: Text(doc.title.isEmpty ? 'Untitled' : doc.title),
                    subtitle: Text(
                      doc.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
                separatorBuilder: (_, _) => const Divider(),
                itemCount: state.documents.length,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
