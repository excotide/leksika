<?php

namespace App\Services;

use App\Models\DeviceToken;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    public function sendToUser(int $userId, string $title, string $body, array $data = []): void
    {
        try {
            $this->send($userId, $title, $body, $data);
        } catch (\Throwable $error) {
            Log::warning('Pengiriman FCM dilewati karena terjadi kesalahan.', [
                'message' => $error->getMessage(),
            ]);
        }
    }

    private function send(int $userId, string $title, string $body, array $data = []): void
    {
        $tokens = DeviceToken::where('user_id', $userId)->pluck('token');

        if ($tokens->isEmpty()) {
            return;
        }

        $accessToken = $this->accessToken();
        $projectId = config('services.firebase.project_id');

        if (!$accessToken || !$projectId) {
            Log::info('FCM dilewati karena kredensial Firebase backend belum dikonfigurasi.');
            return;
        }

        foreach ($tokens as $token) {
            $response = Http::timeout(5)
                ->withToken($accessToken)
                ->acceptJson()
                ->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", [
                    'message' => [
                        'token' => $token,
                        'notification' => [
                            'title' => $title,
                            'body' => $body,
                        ],
                        'data' => array_map('strval', $data),
                        'android' => [
                            'priority' => 'HIGH',
                            'notification' => [
                                'channel_id' => 'leksika_notifications',
                                'sound' => 'default',
                            ],
                        ],
                    ],
                ]);

            if ($response->failed()) {
                Log::warning('Gagal mengirim FCM.', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                if (in_array($response->status(), [400, 404], true)) {
                    DeviceToken::where('token', $token)->delete();
                }
            }
        }
    }

    private function accessToken(): ?string
    {
        $credentials = $this->credentials();
        if (!$credentials) {
            return null;
        }

        $now = time();
        $header = $this->base64UrlEncode(json_encode([
            'alg' => 'RS256',
            'typ' => 'JWT',
        ], JSON_THROW_ON_ERROR));

        $claim = $this->base64UrlEncode(json_encode([
            'iss' => $credentials['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600,
        ], JSON_THROW_ON_ERROR));

        $unsignedJwt = "{$header}.{$claim}";
        $signature = '';
        openssl_sign($unsignedJwt, $signature, $credentials['private_key'], OPENSSL_ALGO_SHA256);
        $jwt = "{$unsignedJwt}." . $this->base64UrlEncode($signature);

        $response = Http::timeout(5)
            ->asForm()
            ->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]);

        if ($response->failed()) {
            Log::warning('Gagal mengambil access token Firebase.', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            return null;
        }

        return $response->json('access_token');
    }

    private function credentials(): ?array
    {
        $rawJson = config('services.firebase.credentials_json');
        if ($rawJson) {
            $credentials = json_decode($rawJson, true);
            return is_array($credentials) ? $credentials : null;
        }

        $path = config('services.firebase.credentials');
        if (!$path || !is_file($path)) {
            return null;
        }

        $credentials = json_decode(file_get_contents($path), true);
        return is_array($credentials) ? $credentials : null;
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
