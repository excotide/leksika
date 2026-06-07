import 'package:bloc/bloc.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/domain/usecases/get_summary_usecase.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_event.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  SummaryBloc({
    required this.getDocumentsUsecase,
    required this.getDocumentDetailUsecase,
    required this.uploadDocumentUsecase,
    required this.createFlashcardsUsecase,
  }) : super(const SummaryInitial()) {
    on<FetchDocumentsRequested>(_onFetchDocuments);
    on<FetchDocumentDetailRequested>(_onFetchDocumentDetail);
    on<UploadDocumentRequested>(_onUploadDocument);
    on<CreateFlashcardsRequested>(_onCreateFlashcards);
  }

  final GetDocumentsUsecase getDocumentsUsecase;
  final GetDocumentDetailUsecase getDocumentDetailUsecase;
  final UploadDocumentUsecase uploadDocumentUsecase;
  final CreateFlashcardsUsecase createFlashcardsUsecase;

  Future<void> _onFetchDocuments(
    FetchDocumentsRequested event,
    Emitter<SummaryState> emit,
  ) async {
    emit(const SummaryLoading());
    final result = await getDocumentsUsecase(
      GetDocumentsParams(search: event.search),
    );
    result.fold(
      (failure) => emit(SummaryFailure(_mapFailure(failure))),
      (documents) => emit(SummaryListLoaded(documents)),
    );
  }

  Future<void> _onFetchDocumentDetail(
    FetchDocumentDetailRequested event,
    Emitter<SummaryState> emit,
  ) async {
    emit(const SummaryLoading());
    final result = await getDocumentDetailUsecase(
      GetDocumentDetailParams(id: event.id),
    );
    result.fold(
      (failure) => emit(SummaryFailure(_mapFailure(failure))),
      (document) => emit(SummaryDetailLoaded(document)),
    );
  }

  Future<void> _onUploadDocument(
    UploadDocumentRequested event,
    Emitter<SummaryState> emit,
  ) async {
    emit(const SummaryLoading());
    final result = await uploadDocumentUsecase(
      UploadDocumentParams(
        filePath: event.filePath,
        length: event.length,
        makeQuiz: event.makeQuiz,
        quizCount: event.quizCount,
      ),
    );
    result.fold(
      (failure) => emit(SummaryFailure(_mapFailure(failure))),
      (document) => emit(SummaryDetailLoaded(document)),
    );
  }

  Future<void> _onCreateFlashcards(
    CreateFlashcardsRequested event,
    Emitter<SummaryState> emit,
  ) async {
    emit(const SummaryLoading());
    final result = await createFlashcardsUsecase(
      CreateFlashcardsParams(id: event.id, quizCount: event.quizCount),
    );
    result.fold(
      (failure) => emit(SummaryFailure(_mapFailure(failure))),
      (document) => emit(SummaryDetailLoaded(document)),
    );
  }

  String _mapFailure(Failure failure) {
    if (failure is EmailNotVerifiedFailure) {
      return 'Email not verified. Please verify OTP.';
    }
    if (failure is UnauthorizedFailure) {
      return 'Unauthorized. Please login again.';
    }
    return failure.message;
  }
}
