<?php

namespace App\Http\Controllers\Api;

use App\Mail\PasswordResetOtpMail;
use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Carbon\Carbon;

class PasswordResetController extends Controller
{
    // STEP 1: Kirim OTP ke email
    public function sendOtp(Request $request)
    {
        $request->validate(['email' => 'required|email|exists:users,email']);

        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = Carbon::now()->addMinutes(10);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $request->email],
            [
                'otp'        => $otp,
                'expires_at' => $expiresAt,
                'token'      => null, // reset token lama
                'created_at' => now(),
            ]
        );

        $user = User::where('email', $request->email)->first();
        Mail::to($request->email)->send(new PasswordResetOtpMail($otp, $user->name));

        return response()->json(['message' => 'OTP berhasil dikirim ke email.']);
    }

    // STEP 2: Verifikasi OTP → kembalikan reset_token
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp'   => 'required|string|size:6',
        ]);

        $record = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->where('otp', $request->otp)
            ->first();

        if (!$record) {
            return response()->json(['message' => 'OTP tidak valid.'], 422);
        }

        if (Carbon::parse($record->expires_at)->isPast()) {
            return response()->json(['message' => 'OTP sudah kedaluwarsa.'], 422);
        }

        // Generate reset_token sementara
        $resetToken = Str::random(64);

        DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->update([
                'token'      => Hash::make($resetToken),
                'otp'        => null, // hapus OTP setelah verified
                'expires_at' => Carbon::now()->addMinutes(15),
            ]);

        return response()->json([
            'message'     => 'OTP valid.',
            'reset_token' => $resetToken, // dikirim ke frontend
        ]);
    }

    // STEP 3: Reset password dengan token
    public function reset(Request $request)
    {
        $request->validate([
            'email'                 => 'required|email',
            'reset_token'           => 'required|string',
            'password'              => 'required|min:8|confirmed',
            // 'password_confirmation' otomatis dicek oleh 'confirmed'
        ]);

        $record = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (!$record || !Hash::check($request->reset_token, $record->token)) {
            return response()->json(['message' => 'Token tidak valid.'], 422);
        }

        if (Carbon::parse($record->expires_at)->isPast()) {
            return response()->json(['message' => 'Token sudah kedaluwarsa.'], 422);
        }

        // Update password user
        User::where('email', $request->email)
            ->update(['password' => Hash::make($request->password)]);

        // Hapus record reset
        DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->delete();

        return response()->json(['message' => 'Password berhasil direset.']);
    }
}