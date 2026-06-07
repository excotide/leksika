<?php

namespace Tests\Feature;

use App\Models\Document;
use App\Models\Summary;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DocumentSearchTest extends TestCase
{
    use RefreshDatabase;

    public function test_document_search_ignores_letter_case(): void
    {
        $user = User::factory()->create();
        $document = Document::create([
            'user_id' => $user->id,
            'file_name' => 'Materi Basis Data',
            'file_path' => 'documents/basis-data.pdf',
        ]);
        Summary::create([
            'document_id' => $document->id,
            'summary_text' => 'Normalisasi Database',
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/documents?search=basis data');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.file_name', 'Materi Basis Data');
    }
}
