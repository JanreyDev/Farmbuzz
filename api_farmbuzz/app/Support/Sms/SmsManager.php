<?php

namespace App\Support\Sms;

use RuntimeException;

class SmsManager
{
    public function driver(): SmsSender
    {
        $driver = (string) config('services.sms.driver', 'log');

        return match ($driver) {
            'log' => new LogSmsSender(),
            'txtbox' => new TxtboxSmsSender(
                url: (string) config('services.sms.txtbox.url'),
                apiKey: (string) config('services.sms.txtbox.api_key'),
                senderName: (string) config('services.sms.txtbox.sender_name', 'FarmBuzz'),
            ),
            'semaphore' => new SemaphoreSmsSender(
                apiKey: (string) config('services.sms.semaphore.key'),
                senderName: (string) config('services.sms.semaphore.sender_name', 'FarmBuzz'),
            ),
            default => throw new RuntimeException("Unsupported SMS driver [{$driver}]."),
        };
    }
}
