<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PostReaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'post_id',
        'reactor_name',
        'reaction',
    ];

    public function post(): BelongsTo
    {
        return $this->belongsTo(Post::class);
    }
}
