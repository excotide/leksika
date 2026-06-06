<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DeviceTokenController;
use App\Http\Controllers\Api\DocumentController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\PasswordResetController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Routes Public (Tanpa Login)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'loginWithGoogle']);

Route::prefix('password')->group(function () {
    Route::post('/forgot',       [PasswordResetController::class, 'sendOtp']);
    Route::post('/verify-otp',   [PasswordResetController::class, 'verifyOtp']);
    Route::post('/reset',        [PasswordResetController::class, 'reset']);
});

// Routes OTP (Butuh Login, Belum Perlu Verified)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/email/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/email/resend-otp', [AuthController::class, 'resendOtp']);
});

// Routes Protected (Harus Login + Verified)
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::post('/fcm-token', [DeviceTokenController::class, 'store']);

    Route::delete('/fcm-token', [DeviceTokenController::class, 'destroy']);

    Route::get('/documents', [DocumentController::class, 'index']);

    Route::post('/documents', [DocumentController::class, 'store']);

    Route::get('/documents/{id}', [DocumentController::class, 'show']);


    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::get('/profile', [ProfileController::class, 'show']);

    Route::put('/profile', [ProfileController::class, 'update']);

    Route::post('/profile/photo', [ProfileController::class, 'uploadPhoto']);

    Route::get('/notifications', [NotificationController::class, 'index']);

    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);

    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);

    Route::post('/notifications/simulate-reminder', [NotificationController::class, 'triggerReminderSimulation']);

    Route::get('/user/streak', function (Request $request) {
        $streakHelper = new \App\Helpers\StreakHelper();
        $streak = $streakHelper->getStreakForDisplay($request->user()->id);
        
        return response()->json([
            'status' => true,
            'data' => $streak
        ]);
    });
});
