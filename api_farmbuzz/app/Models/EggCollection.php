<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EggCollection extends Model
{
    use HasFactory;

    protected $fillable = [
        'farm_id',
        'batch_name',
        'egg_count',
        'collected_on',
        'note',
        'status',
    ];

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }
}
