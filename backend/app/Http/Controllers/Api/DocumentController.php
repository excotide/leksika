<?php

namespace App\Http\Controllers\Api;

use App\Helpers\StreakHelper;
use App\Http\Controllers\Controller;
use App\Jobs\SendQuizReminderJob;
use App\Models\Document;
use App\Models\Summary;
use App\Models\Flashcard; 
use App\Models\Notification; 
use App\Services\FcmService;
use App\Services\SummaryService;
use App\Support\DocumentTitleFormatter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str; 

class DocumentController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $search = trim((string) $request->query('search', ''));
        $historyQuery = Document::where('user_id', $user->id)
            ->with(['summary', 'flashcards', 'notifications']);

        if ($search !== '') {
            $searchPattern = '%' . mb_strtolower($search) . '%';

            $historyQuery->where(function ($query) use ($searchPattern) {
                $query
                    ->whereRaw('LOWER(file_name) LIKE ?', [$searchPattern])
                    ->orWhereHas('summary', function ($summaryQuery) use ($searchPattern) {
                        $summaryQuery->whereRaw('LOWER(summary_text) LIKE ?', [$searchPattern]);
                    })
                    ->orWhereHas('flashcards', function ($flashcardQuery) use ($searchPattern) {
                        $flashcardQuery
                            ->whereRaw('LOWER(question) LIKE ?', [$searchPattern])
                            ->orWhereRaw('LOWER(answer) LIKE ?', [$searchPattern]);
                    });
            });
        }

        $history = $historyQuery->latest()->get();

        return response()->json([
            'status' => true,
            'message' => 'Riwayat berhasil diambil.',
            'data' => $history
        ]);
    }

    public function store(Request $request, SummaryService $aiService)
    {
        $validated = $request->validate([
            'file' => ['required', 'file', 'mimes:pdf,txt,docx', 'max:20480'],
            'length' => ['nullable', 'string'],
            'make_quiz' => ['nullable', 'string'],
            'quiz_count' => ['nullable', 'string'],
        ]);

        DB::beginTransaction();

        try {
            $file = $validated['file'];
            $path = $file->store('documents');
            $absolutePath = Storage::disk('local')->path($path);
            $documentTitle = DocumentTitleFormatter::format($file->getClientOriginalName());

            $document = Document::create([
                'user_id' => $request->user()->id,
                'file_name' => $documentTitle,
                'file_path' => $path,
            ]);

            $text = $aiService->extractText($absolutePath);

            if (!$text || strlen(trim($text)) < 10) {
                throw new \Exception("File tidak memiliki teks yang cukup untuk dirangkum.");
            }

            $cleanText = $text;
            $patterns = [
                '/\bREFERENSI\b/i', 
                '/\bDAFTAR PUSTAKA\b/i', 
                '/\bREFERENCES\b/i',
                '/\bBIBLIOGRAPHY\b/i',
                '/\bUCAPAN TERIMAKASIH\b/i', 
                '/\bACKNOWLEDGEMENT\b/i'
            ];

            foreach ($patterns as $pattern) {
                if (preg_match($pattern, $cleanText, $matches, PREG_OFFSET_CAPTURE)) {
                    $offset = $matches[0][1]; 
                    $cleanText = substr($cleanText, 0, $offset); 
                    break; 
                }
            }

            $document->update([
                'extracted_text' => $cleanText,
                'extraction_engine' => (string) config('document_extraction.engine', 'php'),
                'file_path' => null,
            ]);

            Storage::delete($path);

            $lengthParam = $request->input('length', 'Sedang');
            $wantsQuiz = filter_var($request->input('make_quiz'), FILTER_VALIDATE_BOOLEAN);
            $quizCountParam = $request->input('quiz_count', '5 Soal');

            $optimizedPrompt = "Anda adalah seorang AI Edukasi yang bertugas melakukan analisis dan dekonstruksi materi akademik secara mendalam.
Tugas Anda adalah membedah teks materi yang diberikan, mengekstrak gagasan utama, teori pokok, metodologi, serta definisi dari SETIAP ISTILAH TEKNIS PENTING yang ada di dalam teks tersebut, lalu menyusunnya ke dalam bentuk poin-poin Markdown yang informatif.

PANDUAN KETAT KONTEN RANGKUMAN:
1. JANGAN HANYA MENYALIN kalimat depan dari setiap paragraf. Anda wajib membedah seluruh isi dokumen. Identifikasi semua istilah khusus, konsep penting, variabel, atau metodologi utama yang khas dari topik dokumen ini, lalu JELASKAN definisinya secara gamblang di dalam materi rangkuman.
2. Setiap konsep penting yang diuraikan wajib dicantumkan sebagai sub-subbab atau poin tebal (bold) beserta penjelasannya agar rangkuman menjadi ringkas namun tetap kaya informasi yang komprehensif.
3. Rangkuman harus menjadi satu-satunya sumber pengetahuan penunjang yang valid untuk menjawab soal kuis di bawahnya. Semua jawaban kuis harus sudah terjawab di dalam teks rangkuman.
4. Struktur penulisan WAJIB menggunakan sintaks Markdown (gunakan judul '##', subbab '###', serta poin tebal '* **[Istilah/Konsep Pokok]**: Penjelasan mendalam').
5. JANGAN menyertakan bagian referensi, daftar pustaka, bibliography, sitasi sumber, ucapan terima kasih, atau daftar penulis di akhir rangkuman. Fokus hanya pada materi inti yang perlu dipelajari.
6. Target panjang konten utama: [$lengthParam].

" . ($wantsQuiz ? "PANDUAN KETAT PENYUSUNAN FLASHCARD/SOAL (ANTI-DUPLIKASI):
7. Buatlah kuis sebanyak [$quizCountParam] soal berdasarkan materi inti yang telah Anda jabarkan di atas. Pertanyaan harus fokus pada konsep keilmuan inti, teori, atau temuan penting dari dokumen.
8. JANGAN PERNAH menulis teks kuis berupa daftar tanya-jawab konvensional atau penjelasan pengantar kuis di dalam teks rangkuman utama. Teks rangkuman harus benar-benar bersih dari format soal.
9. Output soal kuis HANYA BOLEH ditulis satu kali saja di bagian paling akhir dokumen, wajib dibungkus di dalam format JSON murni array terlampir di bawah ini agar sistem saya bisa membacanya otomatis:
[
  {
    \"question\": \"Pertanyaan konseptual yang menguji pemahaman materi pokok\",
    \"answer\": \"Jawaban singkat, tepat, dan padat.\"
  }
]" : "");

            $summaryText = $aiService->getGroqSummary(
                $cleanText,             
                $optimizedPrompt,   
                $wantsQuiz,
                $quizCountParam
            );

            if (
                !$summaryText || 
                strlen(trim($summaryText)) < 20 || 
                Str::contains(strtolower($summaryText), ['gagal merangkum', 'maaf, ai gagal', 'tidak dapat merangkum', 'cannot summarize'])
            ) {
                throw new \Exception("Rangkuman belum berhasil dibuat dari dokumen ini.");
            }

            $flashcardSavedCount = 0;
            $pureSummary = $summaryText;
            $flashcardJson = null;

            if (preg_match('/\[\s*\{.*\}\s*\]/s', $summaryText, $matches)) {
                $flashcardJson = $matches[0]; 
                $pureSummary = trim(str_replace($flashcardJson, '', $summaryText));
            }

            $pureSummary = preg_replace('/(\*\*|#)*\s*(Soal Kuis|Pertanyaan dan Jawaban|Kuis|Latihan|Flashcard|Jawaban).*/is', '', $pureSummary);
            $pureSummary = $this->removeReferenceSections($pureSummary);
            $pureSummary = trim($pureSummary);

            $summary = Summary::create([
                'document_id' => $document->id,
                'summary_text' => $pureSummary,
            ]);

            if ($wantsQuiz && $flashcardJson) {
                $quizArray = json_decode($flashcardJson, true);

                if (is_array($quizArray)) {
                    foreach ($quizArray as $quiz) {
                        if (isset($quiz['question']) && isset($quiz['answer'])) {
                            Flashcard::create([
                                'user_id'     => $request->user()->id,
                                'document_id' => $document->id,
                                'question'    => $quiz['question'],
                                'answer'      => $quiz['answer'],
                            ]);
                            $flashcardSavedCount++; 
                        }
                    }
                }
            }

            $summaryNotification = Notification::create([
                'user_id'     => $request->user()->id,
                'document_id' => $document->id,
                'title'       => 'Rangkuman Siap! 📚',
                'message'     => "Rangkuman untuk dokumen " . $documentTitle . " sudah siap! Yuk pelajari materi intinya sekarang.",
                'type'        => 'summary_success',
                'is_read'     => DB::raw('false')
            ]);

            app(FcmService::class)->sendToUser(
                $request->user()->id,
                $summaryNotification->title,
                $summaryNotification->message,
                [
                    'notification_id' => $summaryNotification->id,
                    'document_id' => $document->id,
                    'type' => $summaryNotification->type,
                ],
            );

            if ($wantsQuiz && $flashcardSavedCount > 0) {
                $quizNotification = Notification::create([
                    'user_id'     => $request->user()->id,
                    'document_id' => $document->id,
                    'title'       => 'Asah Otak Sekarang! 🧠',
                    'message'     => "Flashcard untuk dokumen " . $documentTitle . " sudah siap. Yuk langsung uji pemahaman awalmu untuk mengunci ingatan!",
                    'type'        => 'quiz_reminder',
                    'is_read'     => DB::raw('false')
                ]);

                app(FcmService::class)->sendToUser(
                    $request->user()->id,
                    $quizNotification->title,
                    $quizNotification->message,
                    [
                        'notification_id' => $quizNotification->id,
                        'document_id' => $document->id,
                        'type' => $quizNotification->type,
                    ],
                );

                \App\Jobs\SendQuizReminderJob::dispatch(
                    $request->user()->id, 
                    $document->id, 
                    3
                )->delay(now()->addDays(3));
            }

            $streakHelper = new StreakHelper();
            $streakHelper->updateStreak($request->user()->id);

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Upload & Rangkuman berhasil.',
                'data' => $document->load(['summary', 'flashcards']), 
            ], 201);

        } catch (\Throwable $e) {
            DB::rollBack();

            if (isset($path)) {
                Storage::delete($path);
            }

            $errorMessage = $e->getMessage();
            $customMessage = 'Proses Rangkuman Gagal.';
            $statusCode = 500;

            if (Str::contains(strtolower($errorMessage), ['context_length', 'too long', 'token limit', '413', 'max tokens'])) {
                $customMessage = 'Dokumen terlalu panjang. Coba gunakan file yang lebih pendek atau pisahkan menjadi beberapa bagian.';
                $statusCode = 400;
            } 
            elseif (Str::contains(strtolower($errorMessage), ['rate_limit', '429', 'unauthenticated', 'api key', 'overloaded', 'unavailable'])) {
                $customMessage = 'Rangkuman belum bisa dibuat karena layanan pemrosesan sedang ramai. Silakan coba beberapa saat lagi.';
                $statusCode = 503;
            }
            elseif (Str::contains(strtolower($errorMessage), ['curl error 28', 'resolving timed out', 'could not resolve host', 'name or service not known', 'connection timed out', 'operation timed out'])) {
                $customMessage = 'Rangkuman belum bisa dibuat karena koneksi pemrosesan sedang bermasalah. Silakan coba lagi beberapa saat lagi.';
                $statusCode = 503;
            }
            elseif (Str::contains(strtolower($errorMessage), ['groq api error', 'groq exception'])) {
                $customMessage = 'Rangkuman belum bisa dibuat saat ini. Silakan coba beberapa saat lagi.';
                $statusCode = 503;
            }
            elseif (
                $errorMessage === "File tidak memiliki teks yang cukup untuk dirangkum." || 
                $errorMessage === "Rangkuman belum berhasil dibuat dari dokumen ini."
            ) {
                $customMessage = $errorMessage;
                $statusCode = 422;
            }

            return response()->json([
                'status' => false,
                'message' => $customMessage,
                'error' => $errorMessage, 
            ], $statusCode);
        }
    }

    public function show(Request $request, $id)
    {
        $document = Document::where('user_id', $request->user()->id)
            ->with(['summary', 'flashcards', 'notifications']) 
            ->find($id);

        if (!$document) {
            return response()->json([
                'status' => false,
                'message' => 'Dokumen tidak ditemukan.'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'data' => $document
        ]);
    }

    public function generateFlashcards(Request $request, SummaryService $aiService, $id)
    {
        $validated = $request->validate([
            'quiz_count' => ['nullable', 'string'],
        ]);

        $document = Document::where('user_id', $request->user()->id)
            ->with(['summary', 'flashcards', 'notifications'])
            ->find($id);

        if (!$document) {
            return response()->json([
                'status' => false,
                'message' => 'Dokumen tidak ditemukan.'
            ], 404);
        }

        if ($document->flashcards->isNotEmpty()) {
            return response()->json([
                'status' => true,
                'message' => 'Flashcard sudah tersedia.',
                'data' => $document,
            ]);
        }

        $sourceText = trim((string) ($document->extracted_text ?: $document->summary?->summary_text));

        if (strlen($sourceText) < 10) {
            return response()->json([
                'status' => false,
                'message' => 'Teks dokumen tidak cukup untuk membuat flashcard.'
            ], 422);
        }

        $quizCountParam = $validated['quiz_count'] ?? '5 Soal';
        $prompt = "Anda adalah AI edukasi Leksika. Buat flashcard sebanyak [$quizCountParam] soal dari materi yang diberikan.
Output HANYA berupa JSON murni array dengan format:
[
  {
    \"question\": \"Pertanyaan konseptual yang menguji pemahaman materi pokok\",
    \"answer\": \"Jawaban singkat, tepat, dan padat.\"
  }
]
Jangan sertakan markdown, pembuka, penutup, atau teks selain JSON.";

        try {
            $flashcardText = $aiService->getGroqSummary(
                $sourceText,
                $prompt,
                true,
                $quizCountParam
            );

            $flashcardJson = $this->extractFlashcardJson($flashcardText);
            $quizArray = $flashcardJson ? json_decode($flashcardJson, true) : null;

            if (!is_array($quizArray)) {
                return response()->json([
                    'status' => false,
                    'message' => 'Flashcard belum berhasil dibuat dari rangkuman ini.'
                ], 422);
            }

            DB::beginTransaction();

            foreach ($quizArray as $quiz) {
                if (!isset($quiz['question'], $quiz['answer'])) {
                    continue;
                }

                Flashcard::create([
                    'user_id' => $request->user()->id,
                    'document_id' => $document->id,
                    'question' => trim((string) $quiz['question']),
                    'answer' => trim((string) $quiz['answer']),
                ]);
            }

            DB::commit();

            $document = $document->fresh(['summary', 'flashcards', 'notifications']);

            if ($document->flashcards->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Flashcard belum berhasil dibuat dari rangkuman ini.'
                ], 422);
            }

            $quizNotification = Notification::create([
                'user_id'     => $request->user()->id,
                'document_id' => $document->id,
                'title'       => 'Asah Otak Sekarang! 🧠',
                'message'     => "Flashcard untuk dokumen " . $document->file_name . " sudah siap. Yuk langsung uji pemahaman awalmu untuk mengunci ingatan!",
                'type'        => 'quiz_reminder',
                'is_read'     => DB::raw('false')
            ]);

            app(FcmService::class)->sendToUser(
                $request->user()->id,
                $quizNotification->title,
                $quizNotification->message,
                [
                    'notification_id' => $quizNotification->id,
                    'document_id' => $document->id,
                    'type' => $quizNotification->type,
                ],
            );

            SendQuizReminderJob::dispatch(
                $request->user()->id,
                $document->id,
                3
            )->delay(now()->addDays(3));

            return response()->json([
                'status' => true,
                'message' => 'Flashcard berhasil dibuat.',
                'data' => $document,
            ], 201);
        } catch (\Throwable $e) {
            if (DB::transactionLevel() > 0) {
                DB::rollBack();
            }

            return response()->json([
                'status' => false,
                'message' => 'Flashcard belum bisa dibuat saat ini. Silakan coba beberapa saat lagi.',
                'error' => $e->getMessage(),
            ], 503);
        }
    }

    private function removeReferenceSections(string $summary): string
    {
        $summary = preg_replace(
            '/(?:^|\n)\s*(?:[#*\s-]*)\s*(Referensi|Daftar Pustaka|References|Bibliography)\b.*$/isu',
            '',
            $summary
        );

        $summary = preg_replace('/\n\s*[-_=]{3,}\s*$/u', '', $summary ?? '');
        $summary = preg_replace('/\n\s*\*\s*$/u', '', $summary ?? '');

        return trim($summary ?? '');
    }

    private function extractFlashcardJson(string $value): ?string
    {
        if (preg_match('/\[\s*\{.*\}\s*\]/s', $value, $matches)) {
            return $matches[0];
        }

        return null;
    }
}
