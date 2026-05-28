<?php

namespace App\Support\Sms;

use Illuminate\Support\Facades\Log;

class LogSmsSender implements SmsSender
{
    public function send(string $to, string $message): void
    {
        Log::info('SMS (log driver)', [
            'to' => $to,
            'message' => $message,
        ]);
    }
}

