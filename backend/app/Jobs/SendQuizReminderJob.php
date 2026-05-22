<?php

namespace App\Models\Notification;
namespace App\Jobs;

use App\Models\Notification;
use App\Models\Document;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendQuizReminderJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $userId;
    protected $documentId;
    protected $currentDay;

    public function __construct($userId, $documentId, $currentDay)
    {
        $this->userId = $userId;
        $this->documentId = $documentId;
        $this->currentDay = $currentDay;
    }

    public function handle(): void
    {
        $user = User::find($this->userId);
        
        $document = Document::where('user_id', $this->userId)
            ->whereHas('flashcards')
            ->latest()
            ->first();

        if (!$user || !$document) {
            Log::info("Job dihentikan karena user atau dokumen ber-flashcard tidak ditemukan.");
            return;
        }

        Notification::create([
            'user_id'     => $this->userId,
            'document_id' => $document->id,
            'title'       => 'Yuk, Review Materi Lagi! 🧠',
            'message'     => "Sudah waktunya mengasah ingatanmu nih. Yuk buka kembali kuis flashcard dari dokumen '" . $document->file_name . "' agar pemahamanmu makin kuat!",
            'type'        => 'quiz_reminder',
            'is_read'     => \Illuminate\Support\Facades\DB::raw('false')
        ]);

        $nextDay = 3;
        $delayInDays = 3;

        if ($this->currentDay == 3) {
            $nextDay = 7;
            $delayInDays = 4; 
        } elseif ($this->currentDay == 7) {
            $nextDay = 14;
            $delayInDays = 7; 
        } else {
            $nextDay = $this->currentDay + 7;
            $delayInDays = 7;
        }

        self::dispatch($this->userId, $document->id, $nextDay)->delay(now()->addDays($delayInDays));

        Log::info("Notifikasi berkala terkirim. Estafet berikutnya (Day {$nextDay}) dijadwalkan.");
    }
}