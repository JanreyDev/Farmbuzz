<?php

namespace App\Support\Sms;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
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
        $attempts = [
            [
                'headers' => [
                    'Accept' => 'application/json',
                    'Content-Type' => 'application/json',
                    'X-API-KEY' => $this->apiKey,
                ],
                'payload' => [
                    'number' => $to,
                    'message' => $message,
                    'sender_name' => $this->senderName,
                ],
            ],
            [
                'headers' => [
                    'Accept' => 'application/json',
                    'Content-Type' => 'application/json',
                    'X-API-KEY' => $this->apiKey,
                ],
                'payload' => [
                    'number' => $to,
                    'message' => $message,
                    'sendername' => $this->senderName,
                ],
            ],
            [
                'headers' => [
                    'Accept' => 'application/json',
                    'Content-Type' => 'application/json',
                ],
                'payload' => [
                    'apikey' => $this->apiKey,
                    'number' => $to,
                    'message' => $message,
                    'sender_name' => $this->senderName,
                ],
            ],
        ];

        $lastResponseStatus = null;
        $lastResponseBody = null;
        $lastError = null;

        foreach ($attempts as $index => $attempt) {
            try {
                $response = Http::withHeaders($attempt['headers'])->post($this->url, $attempt['payload']);
                $lastResponseStatus = $response->status();
                $lastResponseBody = $response->body();

                if ($response->successful()) {
                    return;
                }

                Log::warning('Txtbox SMS attempt failed', [
                    'attempt' => $index + 1,
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
            } catch (\Throwable $e) {
                $lastError = $e->getMessage();
                Log::error('Txtbox SMS transport error', [
                    'attempt' => $index + 1,
                    'error' => $lastError,
                ]);
            }
        }

        throw new RuntimeException(sprintf(
            'Failed to send SMS OTP via Txtbox. status=%s body=%s error=%s',
            (string) ($lastResponseStatus ?? 'n/a'),
            (string) ($lastResponseBody ?? 'n/a'),
            (string) ($lastError ?? 'n/a')
        ));
    }
}
