<?php

namespace App\Services;

use App\Services\PdfTextExtractor;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use PhpOffice\PhpWord\IOFactory;

class SummaryService
{
    protected $extractor;

    public function __construct(PdfTextExtractor $extractor)
    {
        $this->extractor = $extractor;
    }

    public function extractText($filePath)
    {
        try {
            $extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));

            if ($extension === 'pdf') {
                $rawText = $this->extractor->extract($filePath);
                return $this->cleanExtractedText($rawText); // Bersihkan teks hasil ekstraksi PDF
            }

            if ($extension === 'docx') {
                $phpWord = IOFactory::load($filePath);
                $fullText = '';

                foreach ($phpWord->getSections() as $section) {
                    foreach ($section->getElements() as $element) {
                        $fullText .= $this->parseWordElement($element) . " ";
                    }
                }
                return $this->cleanExtractedText($fullText); // Bersihkan teks hasil ekstraksi DOCX
            }

            return $this->cleanExtractedText(file_get_contents($filePath));
        } catch (\Exception $e) {
            Log::error("Ekstraksi gagal: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Fitur Baru: Pembersih Teks Otomatis (Anti-Karakter Sampah)
     */
    private function cleanExtractedText($text)
    {
        if (!$text) return '';

        // 1. Bersihkan rumus matematika rusak & karakter aneh yang tidak bisa dibaca manusia
        // Menghapus karakter non-alphanumeric yang berulang secara acak (simbol sampah)
        $text = preg_replace('/[!\"#\$&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?@\[\\\]\^_\`\{\|\}\~]{3,}/', ' ', $text);

        // 2. Bersihkan penanda halaman jurnal/spasi renggang yang berlebihan (\t \n beruntun)
        $text = preg_replace('/[\t\n\r]+/', " \n ", $text);

        // 3. Hapus spasi ganda horizontal agar teks merapat rapi
        $text = preg_replace('/[ ]+/', ' ', $text);

        // 4. Hapus baris kosong yang tidak ada teksnya sama sekali
        $text = preg_replace_callback('/(\n\s*){2,}/', function($matches) {
            return "\n";
        }, $text);

        return trim($text);
    }

    private function parseWordElement($element)
    {
        $text = '';

        if (method_exists($element, 'getText')) {
            $content = $element->getText();
            return is_string($content) ? $content : '';
        }

        if (method_exists($element, 'getElements')) {
            foreach ($element->getElements() as $childElement) {
                $text .= $this->parseWordElement($childElement);
            }
        }

        return $text;
    }

    /**
     * Menyesuaikan parameter agar menerima $optimizedPrompt secara benar dari Controller
     */
    public function getGroqSummary($text, $optimizedPrompt, $makeQuiz = false, $quizCount = "5 Soal")
    {
        // Batasi token agar tidak terkena Context Window Limit (Max 20.000 Karakter)
        $cleanText = mb_strimwidth($text, 0, 12000, "...");

        $apiKey = env('GROQ_API_KEY');
        $url = "https://api.groq.com/openai/v1/chat/completions";

        if (!$text) return "Teks kosong, tidak ada konten untuk dirangkum.";

        // Jika Controller mengirimkan $optimizedPrompt, kita gunakan prompt tersebut sebagai instruksi sistem.
        // Jika tidak, gunakan instruksi default (fallback).
        $systemInstructions = !empty($optimizedPrompt) ? $optimizedPrompt : "Anda adalah asisten akademik Leksika yang ahli merangkum materi kuliah dalam Bahasa Indonesia.";

        try {
            $response = Http::withToken($apiKey)
                ->timeout(120)
                ->post($url, [
                    "model" => "llama-3.1-8b-instant",
                    "messages" => [
                        [
                            "role" => "system",
                            "content" => $systemInstructions
                        ],
                        [
                            "role" => "user",
                            "content" => "Materi yang harus diproses:\n" . $cleanText
                        ]
                    ],
                    "temperature" => 0.3 // Diturunkan ke 0.3 agar AI lebih disiplin mengikuti format Markdown & JSON
                ]);

            if ($response->successful()) {
                return $response->json()['choices'][0]['message']['content'];
            }

            Log::error("Groq API Error: " . $response->body());
            
            // Lemparkan exception asli agar ditangkap oleh Exception Handler di Controller kamu
            throw new \Exception("Groq API Error: " . $response->body());

        } catch (\Exception $e) {
            Log::error("Groq Exception: " . $e->getMessage());
            // Lemparkan ke controller agar proses database di-rollback
            throw new \Exception($e->getMessage());
        }
    }
}