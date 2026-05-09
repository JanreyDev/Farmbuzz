<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FlockBatch extends Model
{
    use HasFactory;

    protected $fillable = [
        'farm_id',
        'name',
        'category',
        'stage',
        'count',
        'started_on',
        'note',
    ];

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }
}
