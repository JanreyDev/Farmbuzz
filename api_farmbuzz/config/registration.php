<?php

return [
    'default_otp' => env('REGISTRATION_DEFAULT_OTP'),
    'otp_length' => env('REGISTRATION_OTP_LENGTH', 6),
    'otp_ttl_minutes' => env('REGISTRATION_OTP_TTL_MINUTES', 10),
];
