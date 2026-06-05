<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @property int         $id
 * @property int         $user_id
 * @property int         $current_streak
 * @property int         $max_streak
 * @property string|null $last_activity_date
 */
class UserStreak extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'current_streak', 'max_streak', 'last_activity_date'];

    protected $casts = [
        'last_activity_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
