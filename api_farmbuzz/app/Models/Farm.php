<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Farm extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'farm_type',
        'city',
        'started_year',
        'birds_count',
        'active_cycles',
        'eggs_incubating',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}