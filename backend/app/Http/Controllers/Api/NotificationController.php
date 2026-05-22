<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\Document; // Wajib di-import untuk mencari file terakhir sebagai bahan kuis
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'status' => true,
            'message' => 'Histori notifikasi berhasil diambil.',
            'data' => $notifications
        ]);
    }

    public function triggerReminderSimulation(Request $request)
    {
        $lastDocument = Document::where('user_id', $request->user()->id)
            ->latest()
            ->first();

        if (!$lastDocument) {
            return response()->json([
                'status' => false,
                'message' => 'Belum ada dokumen yang diupload untuk dijadikan bahan pengingat belajar.'
            ], 422);
        }

        $notification = Notification::create([
            'user_id'     => $request->user()->id,
            'document_id' => $lastDocument->id,
            'title'       => 'Yuk, Review Materi Lagi! 🧠',
            'message'     => "Sudah waktunya mengasah ingatanmu nih. Yuk buka kembali kuis flashcard dari dokumen '" . $lastDocument->file_name . "' agar pemahamanmu makin kuat!",
            'type'        => 'quiz_reminder',
            'is_read'     => \Illuminate\Support\Facades\DB::raw('false')
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Simulasi Notifikasi Pengingat Belajar (quiz_reminder) berhasil dibuat.',
            'data' => $notification
        ], 201);
    }

    public function markAsRead($id, Request $request)
    {
        $notification = Notification::where('user_id', $request->user()->id)->find($id);

        if ($notification) {
            $notification->update(['is_read' => \Illuminate\Support\Facades\DB::raw('true')]);
            return response()->json([
                'status' => true, 
                'message' => 'Notifikasi berhasil ditandai telah dibaca.'
            ]);
        }

        return response()->json(['status' => false, 'message' => 'Data tidak ditemukan.'], 404);
    }

    public function markAllAsRead(Request $request)
    {
        $updatedRows = Notification::where('user_id', $request->user()->id)
            ->where('is_read', \Illuminate\Support\Facades\DB::raw('false'))
            ->update(['is_read' => \Illuminate\Support\Facades\DB::raw('true')]);

        return response()->json([
            'status' => true,
            'message' => 'Semua notifikasi berhasil ditandai telah dibaca.',
            'total_updated' => $updatedRows
        ]);
    }
}
