<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HeritageLine extends Model
{
    use HasFactory;

    protected $fillable = [
        'farm_id',
        'name',
        'description',
        'origin_focus',
        'traits',
        'generations_bred',
    ];

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }
}
