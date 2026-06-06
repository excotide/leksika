<?php

namespace App\Support;

class DocumentTitleFormatter
{
    public static function format(string $value): string
    {
        $withoutExtension = preg_replace('/\.[a-zA-Z0-9]+$/', '', $value) ?? '';
        $cleaned = preg_replace('/[_+\-]+/', ' ', $withoutExtension) ?? '';
        $cleaned = preg_replace('/[^\p{L}\p{N}\s]/u', ' ', $cleaned) ?? '';
        $cleaned = preg_replace('/\b\d{3,}\b/u', ' ', $cleaned) ?? '';
        $cleaned = trim(preg_replace('/\s+/', ' ', $cleaned) ?? '');

        if ($cleaned === '') {
            return 'Tanpa Judul';
        }

        $words = preg_split('/\s+/', $cleaned) ?: [];
        $words = array_filter($words, fn (string $word): bool => !ctype_digit($word));

        $formattedWords = array_map(function (string $word): string {
            if (strlen($word) <= 2 && strtoupper($word) === $word) {
                return $word;
            }

            $lower = mb_strtolower($word, 'UTF-8');
            return mb_strtoupper(mb_substr($lower, 0, 1, 'UTF-8'), 'UTF-8')
                . mb_substr($lower, 1, null, 'UTF-8');
        }, array_filter($words));

        return implode(' ', $formattedWords);
    }
}
