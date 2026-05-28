<?php

namespace App\Support\Sms;

interface SmsSender
{
    public function send(string $to, string $message): void;
}

