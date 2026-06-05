<?php

namespace App\Http\Controllers\Api;

use App\Helpers\StreakHelper;
use App\Http\Controllers\Controller;
use App\Models\Summary;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    /**
     * Susun data user untuk response (termasuk avatar_url).
     */
    private function formatUser(User $user): array
    {
        // Gunakan domain dari request agar URL avatar selalu benar di semua
        // environment (lokal, production, dll) tanpa tergantung APP_URL di .env.
        $avatarUrl = null;
        if ($user->avatar_path) {
            $avatarUrl = request()->getSchemeAndHttpHost()
                . '/storage/'
                . $user->avatar_path;
        }

        return [
            'name'        => $user->name,
            'email'       => $user->email,
            'bio'         => $user->bio,
            'institution' => $user->institution,
            'address'     => $user->address,
            'avatar_url'  => $avatarUrl,
        ];
    }

    /**
     * GET /profile
     */
    public function show(Request $request)
    {
        $user = $request->user();

        $totalSummary = Summary::whereHas('document', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        })->count();

        $streak = (new StreakHelper())->getStreakForDisplay($user->id);

        return response()->json([
            'status' => true,
            'message' => 'Profil berhasil diambil.',
            'data' => array_merge($this->formatUser($user), [
                'total_summary' => $totalSummary,
                'total_streak'  => $streak->current_streak,
            ]),
        ]);
    }

    /**
     * PUT /profile
     */
    public function update(Request $request)
    {
        $validated = $request->validate([
            'name'        => ['sometimes', 'required', 'string', 'max:255'],
            'bio'         => ['nullable', 'string', 'max:1000'],
            'institution' => ['nullable', 'string', 'max:255'],
            'address'     => ['nullable', 'string', 'max:255'],
        ]);

        $user = $request->user();
        $user->update($validated);

        return response()->json([
            'status' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data' => $this->formatUser($user),
        ]);
    }

    /**
     * POST /profile/photo
     */
    public function uploadPhoto(Request $request)
    {
        $request->validate([
            'photo' => ['required', 'image', 'mimes:jpeg,jpg,png', 'max:5120'],
        ]);

        $user = $request->user();

        DB::transaction(function () use ($request, $user) {
            $oldPath = $user->avatar_path;

            // Simpan file baru DULU
            $path = $request->file('photo')->store('avatars', 'public');

            // Update DB — jika gagal, transaction rollback & file baru tidak jadi orphan
            $user->update(['avatar_path' => $path]);

            // Hapus file lama SETELAH update DB berhasil
            if ($oldPath) {
                Storage::disk('public')->delete($oldPath);
            }
        });

        return response()->json([
            'status' => true,
            'message' => 'Foto profil berhasil diperbarui.',
            'data' => $this->formatUser($user->fresh()),
        ]);
    }
}
