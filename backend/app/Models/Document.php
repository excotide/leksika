<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Document extends Model
{
    protected $fillable = ['user_id', 'file_name', 'file_path', 'extracted_text', 'extraction_engine'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function summary()
    {
        return $this->hasOne(Summary::class);
    }

    public function flashcards()
    {
        return $this->hasMany(Flashcard::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }
}
