<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Post extends Model
{
    use HasFactory;

    protected $fillable = [
        'club_id',
        'author_name',
        'author_avatar',
        'content',
        'meta_feeling',
        'meta_location',
        'image_paths',
        'shared_post_data',
        'likes_count',
        'comments_count',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'image_paths' => 'array',
            'shared_post_data' => 'array',
            'published_at' => 'datetime',
        ];
    }

    public function club()
    {
        return $this->belongsTo(Club::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    public function reactions(): HasMany
    {
        return $this->hasMany(PostReaction::class);
    }
}
