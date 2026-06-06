<?php

namespace App\Http\Controllers\Api;

use App\Helpers\StreakHelper;
use App\Http\Controllers\Controller;
use App\Models\Document;
use App\Models\Summary;
use App\Models\Flashcard; 
use App\Models\Notification; 
use App\Services\SummaryService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str; 

class DocumentController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $history = Document::where('user_id', $user->id)
            ->with(['summary', 'flashcards', 'notifications']) 
            ->latest()
            ->get();

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

            $document = Document::create([
                'user_id' => $request->user()->id,
                'file_name' => $file->getClientOriginalName(),
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
            ]);

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
5. Target panjang konten utama: [$lengthParam].

" . ($wantsQuiz ? "PANDUAN KETAT PENYUSUNAN FLASHCARD/SOAL (ANTI-DUPLIKASI):
6. Buatlah kuis sebanyak [$quizCountParam] soal berdasarkan materi inti yang telah Anda jabarkan di atas. Pertanyaan harus fokus pada konsep keilmuan inti, teori, atau temuan penting dari dokumen.
7. JANGAN PERNAH menulis teks kuis berupa daftar tanya-jawab konvensional atau penjelasan pengantar kuis di dalam teks rangkuman utama. Teks rangkuman harus benar-benar bersih dari format soal.
8. Output soal kuis HANYA BOLEH ditulis satu kali saja di bagian paling akhir dokumen, wajib dibungkus di dalam format JSON murni array terlampir di bawah ini agar sistem saya bisa membacanya otomatis:
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
                throw new \Exception("AI gagal menghasilkan output rangkuman yang valid untuk dokumen ini.");
            }

            $flashcardSavedCount = 0;
            $pureSummary = $summaryText;
            $flashcardJson = null;

            if (preg_match('/\[\s*\{.*\}\s*\]/s', $summaryText, $matches)) {
                $flashcardJson = $matches[0]; 
                $pureSummary = trim(str_replace($flashcardJson, '', $summaryText));
            }

            $pureSummary = preg_replace('/(\*\*|#)*\s*(Soal Kuis|Pertanyaan dan Jawaban|Kuis|Latihan|Flashcard|Jawaban).*/is', '', $pureSummary);
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

            Notification::create([
                'user_id'     => $request->user()->id,
                'document_id' => $document->id,
                'title'       => 'Rangkuman Siap! 📚',
                'message'     => "Rangkuman untuk dokumen " . $file->getClientOriginalName() . " sudah siap! Yuk pelajari materi intinya sekarang.",
                'type'        => 'summary_success',
                'is_read'     => DB::raw('false')
            ]);

            if ($wantsQuiz && $flashcardSavedCount > 0) {
                Notification::create([
                    'user_id'     => $request->user()->id,
                    'document_id' => $document->id,
                    'title'       => 'Asah Otak Sekarang! 🧠',
                    'message'     => "Rangkuman & Flashcard sudah siap. Yuk langsung uji pemahaman awalmu untuk mengunci ingatan!",
                    'type'        => 'quiz_reminder',
                    'is_read'     => DB::raw('false')
                ]);

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
                $customMessage = 'Dokumen terlalu panjang! Batasi isi dokumen atau potong menjadi beberapa bagian agar dapat diproses oleh AI.';
                $statusCode = 400;
            } 
            elseif (Str::contains(strtolower($errorMessage), ['rate_limit', '429', 'unauthenticated', 'api key', 'overloaded', 'unavailable'])) {
                $customMessage = 'Server AI sedang sangat sibuk atau mencapai batas limit harian. Silakan coba beberapa saat lagi.';
                $statusCode = 503;
            }
            elseif (Str::contains(strtolower($errorMessage), ['curl error 28', 'resolving timed out', 'could not resolve host', 'name or service not known', 'connection timed out', 'operation timed out'])) {
                $customMessage = 'Server AI sedang tidak dapat dihubungi. Periksa koneksi internet backend lalu coba lagi.';
                $statusCode = 503;
            }
            elseif (Str::contains(strtolower($errorMessage), ['groq api error', 'groq exception'])) {
                $customMessage = 'Layanan AI gagal memproses dokumen saat ini. Silakan coba beberapa saat lagi.';
                $statusCode = 503;
            }
            elseif (
                $errorMessage === "File tidak memiliki teks yang cukup untuk dirangkum." || 
                $errorMessage === "AI gagal menghasilkan output rangkuman yang valid untuk dokumen ini."
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
}
