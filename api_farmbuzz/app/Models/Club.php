<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Club extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'category',
        'region',
        'focus_tags',
        'is_public',
        'min_birds',
        'verified_only',
        'cover_image_url',
        'member_count',
        'post_count',
    ];

    protected $casts = [
        'focus_tags' => 'array',
        'is_public' => 'boolean',
        'verified_only' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

