<?php

namespace Tests\Feature;

use App\Jobs\SendQuizReminderJob;
use App\Models\Document;
use App\Models\Summary;
use App\Models\User;
use App\Services\FcmService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Mockery;
use Tests\TestCase;

class QuizReminderJobTest extends TestCase
{
    use RefreshDatabase;

    public function test_reminder_uses_the_document_passed_to_the_job(): void
    {
        Queue::fake();

        $user = User::factory()->create();

        $targetDocument = Document::create([
            'user_id' => $user->id,
            'file_name' => 'Dokumen Lama Baru Dibuat Flashcard',
            'file_path' => 'documents/lama.pdf',
        ]);
        $targetDocument->forceFill([
            'created_at' => now()->subMonth(),
            'updated_at' => now()->subMonth(),
        ])->save();
        Summary::create([
            'document_id' => $targetDocument->id,
            'summary_text' => 'Ringkasan dokumen lama.',
        ]);
        $targetDocument->flashcards()->create([
            'user_id' => $user->id,
            'question' => 'Pertanyaan baru',
            'answer' => 'Jawaban baru',
        ]);

        $newerDocument = Document::create([
            'user_id' => $user->id,
            'file_name' => 'Dokumen Lebih Baru',
            'file_path' => 'documents/baru.pdf',
        ]);
        $newerDocument->forceFill([
            'created_at' => now(),
            'updated_at' => now(),
        ])->save();
        $newerDocument->flashcards()->create([
            'user_id' => $user->id,
            'question' => 'Pertanyaan lain',
            'answer' => 'Jawaban lain',
        ]);

        $fcmService = Mockery::mock(FcmService::class);
        $fcmService->shouldReceive('sendToUser')->once();
        $this->app->instance(FcmService::class, $fcmService);

        (new SendQuizReminderJob($user->id, $targetDocument->id, 3))->handle();

        $this->assertDatabaseHas('notifications', [
            'user_id' => $user->id,
            'document_id' => $targetDocument->id,
            'type' => 'quiz_reminder',
            'message' => "Sudah waktunya mengasah ingatanmu nih. Yuk buka kembali kuis flashcard dari dokumen 'Dokumen Lama Baru Dibuat Flashcard' agar pemahamanmu makin kuat!",
        ]);
        $this->assertDatabaseMissing('notifications', [
            'user_id' => $user->id,
            'document_id' => $newerDocument->id,
            'type' => 'quiz_reminder',
        ]);
    }
}
