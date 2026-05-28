<?php

namespace App\Support\Sms;

use Illuminate\Support\Facades\Http;
use RuntimeException;

class TxtboxSmsSender implements SmsSender
{
    public function __construct(
        private readonly string $url,
        private readonly string $apiKey,
        private readonly string $senderName,
    ) {
    }

    public function send(string $to, string $message): void
    {
        if (blank($this->url) || blank($this->apiKey)) {
            throw new RuntimeException('Txtbox SMS credentials are not configured.');
        }

        $response = Http::withHeaders([
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
            'X-API-KEY' => $this->apiKey,
        ])->post($this->url, [
            'number' => $to,
            'message' => $message,
            'sender_name' => $this->senderName,
        ]);

        if ($response->failed()) {
            throw new RuntimeException('Failed to send SMS OTP via Txtbox.');
        }
    }
}

