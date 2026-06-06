<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DeviceToken;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'token' => ['required', 'string'],
            'platform' => ['nullable', 'string', 'max:50'],
        ]);

        DeviceToken::updateOrCreate(
            ['token' => $validated['token']],
            [
                'user_id' => $request->user()->id,
                'platform' => $validated['platform'] ?? 'android',
                'last_used_at' => now(),
            ],
        );

        return response()->json([
            'status' => true,
            'message' => 'Token notifikasi berhasil disimpan.',
        ]);
    }

    public function destroy(Request $request)
    {
        $validated = $request->validate([
            'token' => ['required', 'string'],
        ]);

        DeviceToken::where('user_id', $request->user()->id)
            ->where('token', $validated['token'])
            ->delete();

        return response()->json([
            'status' => true,
            'message' => 'Token notifikasi berhasil dihapus.',
        ]);
    }
}
