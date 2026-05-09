<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SocialConnection extends Model
{
    use HasFactory;

    protected $fillable = [
        'owner_user_id',
        'target_user_id',
        'relation',
    ];
}
