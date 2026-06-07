<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_profile_response_includes_public_avatar_url_with_cache_buster(): void
    {
        $user = User::factory()->create([
            'avatar_path' => 'avatars/foto-profil.jpg',
            'updated_at' => now(),
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/profile');

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.avatar_url',
                url('/storage/avatars/foto-profil.jpg') . '?v=' . $user->updated_at->timestamp,
            );
    }
}
