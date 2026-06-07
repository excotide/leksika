<?php

namespace Tests\Feature;

use App\Models\Document;
use App\Models\Summary;
use App\Models\User;
use App\Jobs\SendQuizReminderJob;
use App\Services\SummaryService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Laravel\Sanctum\Sanctum;
use Mockery;
use Tests\TestCase;

class GenerateFlashcardsTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_generate_flashcards_for_existing_summary(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $document = Document::create([
            'user_id' => $user->id,
            'file_name' => 'Materi Basis Data',
            'file_path' => 'documents/materi.txt',
            'extracted_text' => 'Normalisasi database mengurangi redundansi data.',
        ]);
        Summary::create([
            'document_id' => $document->id,
            'summary_text' => 'Normalisasi membantu struktur tabel lebih rapi.',
        ]);

        $summaryService = Mockery::mock(SummaryService::class);
        $summaryService
            ->shouldReceive('getGroqSummary')
            ->once()
            ->andReturn('[{"question":"Apa tujuan normalisasi?","answer":"Mengurangi redundansi data."}]');
        $this->app->instance(SummaryService::class, $summaryService);

        Sanctum::actingAs($user);

        $response = $this->postJson("/api/documents/{$document->id}/flashcards", [
            'quiz_count' => '1 Soal',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.flashcards.0.question', 'Apa tujuan normalisasi?');

        $this->assertDatabaseHas('flashcards', [
            'user_id' => $user->id,
            'document_id' => $document->id,
            'question' => 'Apa tujuan normalisasi?',
            'answer' => 'Mengurangi redundansi data.',
        ]);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $user->id,
            'document_id' => $document->id,
            'title' => 'Asah Otak Sekarang! 🧠',
            'message' => "Flashcard untuk dokumen Materi Basis Data sudah siap. Yuk langsung uji pemahaman awalmu untuk mengunci ingatan!",
            'type' => 'quiz_reminder',
            'is_read' => false,
        ]);

        Queue::assertPushed(SendQuizReminderJob::class);
    }

    public function test_existing_flashcards_are_returned_without_regenerating(): void
    {
        $user = User::factory()->create();
        $document = Document::create([
            'user_id' => $user->id,
            'file_name' => 'Materi Jaringan',
            'file_path' => 'documents/jaringan.txt',
            'extracted_text' => 'DNS menerjemahkan nama domain.',
        ]);
        Summary::create([
            'document_id' => $document->id,
            'summary_text' => 'DNS memudahkan akses website.',
        ]);
        $document->flashcards()->create([
            'user_id' => $user->id,
            'question' => 'Apa fungsi DNS?',
            'answer' => 'Menerjemahkan nama domain.',
        ]);

        $summaryService = Mockery::mock(SummaryService::class);
        $summaryService->shouldNotReceive('getGroqSummary');
        $this->app->instance(SummaryService::class, $summaryService);

        Sanctum::actingAs($user);

        $response = $this->postJson("/api/documents/{$document->id}/flashcards");

        $response
            ->assertOk()
            ->assertJsonPath('message', 'Flashcard sudah tersedia.')
            ->assertJsonPath('data.flashcards.0.question', 'Apa fungsi DNS?');
    }
}
