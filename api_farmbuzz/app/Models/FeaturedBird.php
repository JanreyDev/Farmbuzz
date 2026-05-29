<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FeaturedBird extends Model
{
    use HasFactory;

    protected $fillable = [
        'farm_id',
        'name',
        'heritage_line',
        'age_label',
        'sex',
        'badge',
        'image_url',
    ];

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }
}

