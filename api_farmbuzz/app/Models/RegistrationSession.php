<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RegistrationSession extends Model
{
    protected $fillable = [
        'name',
        'referral_code',
        'is_at_least_18',
        'accepted_terms',
        'mobile_number',
        'otp_code',
        'otp_sent_at',
        'mobile_verified_at',
        'registration_status',
    ];

    protected function casts(): array
    {
        return [
            'is_at_least_18' => 'boolean',
            'accepted_terms' => 'boolean',
            'otp_sent_at' => 'datetime',
            'mobile_verified_at' => 'datetime',
        ];
    }
}

