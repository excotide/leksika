<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Mail\OtpMail;
use App\Models\EmailOtp;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;

class AuthController extends Controller
{
    // --- REGISTRASI ---
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status'  => false,
                'message' => $validator->errors(),
            ], 422);
        }

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Generate & simpan OTP
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        EmailOtp::updateOrCreate(
            ['user_id' => $user->id],
            [
                'otp'        => $otp,
                'expires_at' => now()->addMinutes(10),
            ]
        );

        // Kirim email OTP
        Mail::to($user->email)->send(new OtpMail($otp, $user->name));

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status'  => true,
            'message' => 'Registrasi berhasil! Cek email untuk kode OTP.',
            'token'   => $token,
            'user'    => $user,
        ], 201);
    }

    // --- VERIFIKASI OTP ---
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'otp' => 'required|string|size:6',
        ]);

        $user     = $request->user();
        $emailOtp = EmailOtp::where('user_id', $user->id)
                            ->where('otp', $request->otp)
                            ->first();

        // Cek OTP valid
        if (!$emailOtp) {
            return response()->json([
                'status'  => false,
                'message' => 'Kode OTP tidak valid.',
            ], 400);
        }

        // Cek OTP kadaluarsa
        if ($emailOtp->expires_at->isPast()) {
            $emailOtp->delete();
            return response()->json([
                'status'  => false,
                'message' => 'Kode OTP sudah kadaluarsa.',
            ], 400);
        }

        // Verifikasi email & hapus OTP
        $user->markEmailAsVerified();
        $emailOtp->delete();

        return response()->json([
            'status'  => true,
            'message' => 'Email berhasil diverifikasi!',
        ]);
    }

    // --- RESEND OTP ---
    public function resendOtp(Request $request)
    {
        $user = $request->user();

        // Cek sudah verified belum
        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'status'  => false,
                'message' => 'Email sudah terverifikasi.',
            ], 400);
        }

        // Generate OTP baru
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        EmailOtp::updateOrCreate(
            ['user_id' => $user->id],
            [
                'otp'        => $otp,
                'expires_at' => now()->addMinutes(10),
            ]
        );

        // Kirim ulang email OTP
        Mail::to($user->email)->send(new OtpMail($otp, $user->name));

        return response()->json([
            'status'  => true,
            'message' => 'Kode OTP baru telah dikirim.',
        ]);
    }

    // --- LOGIN ---
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'status'  => false,
                'message' => 'Email atau password salah.',
            ], 401);
        }

        $user = Auth::user();

        // Tolak login kalau belum verifikasi
        if (!$user->hasVerifiedEmail()) {
            return response()->json([
                'status'  => false,
                'message' => 'Email belum diverifikasi. Cek inbox kamu!',
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status'  => true,
            'message' => 'Login berhasil!',
            'token'   => $token,
            'user'    => $user,
        ]);
    }

    // --- LOGOUT ---
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status'  => true,
            'message' => 'Berhasil logout.',
        ]);
    }

    // --- LOGIN WITH GOOGLE ---
    public function loginWithGoogle(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        // Verifikasi idToken ke Google
        $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $request->id_token,
        ]);

        if ($response->failed()) {
            return response()->json([
                'status'  => false,
                'message' => 'Token Google tidak valid.',
            ], 401);
        }

        $googleUser = $response->json();

        // Pastikan token valid
        if (!isset($googleUser['email'])) {
            return response()->json([
                'status'  => false,
                'message' => 'Gagal mendapatkan data dari Google.',
            ], 401);
        }

        // Cari atau buat user
        $user = User::firstOrCreate(
            ['email' => $googleUser['email']],
            [
                'name'              => $googleUser['name'] ?? $googleUser['email'],
                'password'          => Hash::make(str()->random(32)),
                'email_verified_at' => now(), // Google sudah verifikasi email
            ]
        );

        // Kalau user lama belum verified, verifikasi sekarang
        if (!$user->hasVerifiedEmail()) {
            $user->markEmailAsVerified();
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status'  => true,
            'message' => 'Login dengan Google berhasil!',
            'token'   => $token,
            'user'    => $user,
        ]);
    }
}