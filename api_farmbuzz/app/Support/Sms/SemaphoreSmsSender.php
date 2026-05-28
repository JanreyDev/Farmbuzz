<?php

namespace App\Support\Sms;

use Illuminate\Support\Facades\Http;
use RuntimeException;

class SemaphoreSmsSender implements SmsSender
{
    public function __construct(
        private readonly string $apiKey,
        private readonly string $senderName,
    ) {
    }

    public function send(string $to, string $message): void
    {
        if (blank($this->apiKey)) {
            throw new RuntimeException('Semaphore API key is not configured.');
        }

        $response = Http::asForm()
            ->post('https://api.semaphore.co/api/v4/messages', [
                'apikey' => $this->apiKey,
                'number' => $to,
                'message' => $message,
                'sendername' => $this->senderName,
            ]);

        if ($response->failed()) {
            throw new RuntimeException('Failed to send SMS OTP.');
        }
    }
}

