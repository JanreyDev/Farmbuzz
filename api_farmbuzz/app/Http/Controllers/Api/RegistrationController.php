<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\SendOtpRequest;
use App\Http\Requests\Auth\SetPinRequest;
use App\Http\Requests\Auth\StartRegistrationRequest;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Models\User;
use App\Support\Sms\SmsManager;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use RuntimeException;

class RegistrationController extends Controller
{
    public function __construct(
        private readonly SmsManager $smsManager,
    ) {
    }

    public function start(StartRegistrationRequest $request): JsonResponse
    {
        $user = User::query()->create([
            'name' => $request->string('name')->toString(),
            'referral_code' => $request->input('referral_code'),
            'is_at_least_18' => true,
            'accepted_terms' => true,
            'registration_status' => 'started',
        ]);

        return response()->json([
            'message' => 'Account setup started.',
            'registration_id' => $user->id,
        ], 201);
    }

    public function sendOtp(SendOtpRequest $request): JsonResponse
    {
        $user = User::query()->findOrFail($request->integer('registration_id'));

        if ($user->registration_status === 'completed') {
            return response()->json(['message' => 'Registration is already completed.'], 422);
        }

        $otp = $this->resolveOtp();

        $user->forceFill([
            'mobile_number' => $request->string('mobile_number')->toString(),
            'otp_code' => Hash::make($otp),
            'otp_sent_at' => now(),
            'mobile_verified_at' => null,
            'registration_status' => 'otp_sent',
        ])->save();

        $mobile = $request->string('mobile_number')->toString();
        $ttl = (int) config('registration.otp_ttl_minutes', 10);

        try {
            $this->smsManager
                ->driver()
                ->send($mobile, "Your FarmBuzz verification code is {$otp}. It expires in {$ttl} minutes.");
        } catch (RuntimeException $e) {
            $message = app()->isLocal()
                ? 'Unable to deliver OTP: '.$e->getMessage()
                : 'Unable to deliver OTP right now. Please contact support or try again later.';
            return response()->json([
                'message' => $message,
            ], 503);
        }

        return response()->json([
            'message' => 'OTP sent successfully.',
        ]);
    }

    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $user = User::query()->findOrFail($request->integer('registration_id'));

        if (blank($user->otp_code) || ! Hash::check($request->string('otp')->toString(), $user->otp_code)) {
            return response()->json(['message' => 'Invalid OTP.'], 422);
        }

        $user->forceFill([
            'mobile_verified_at' => now(),
            'registration_status' => 'otp_verified',
        ])->save();

        return response()->json([
            'message' => 'Mobile number verified successfully.',
        ]);
    }

    public function setPin(SetPinRequest $request): JsonResponse
    {
        $user = User::query()->findOrFail($request->integer('registration_id'));

        if (blank($user->mobile_verified_at)) {
            return response()->json(['message' => 'Please verify your mobile number first.'], 422);
        }

        $user->forceFill([
            'pin' => Hash::make($request->string('pin')->toString()),
            'otp_code' => null,
            'registration_status' => 'completed',
            'registration_completed_at' => now(),
        ])->save();

        return response()->json([
            'message' => 'PIN set successfully. Registration completed.',
        ]);
    }

    private function resolveOtp(): string
    {
        $defaultOtp = config('registration.default_otp');
        if (is_string($defaultOtp) && preg_match('/^\d{6}$/', $defaultOtp) === 1) {
            return $defaultOtp;
        }

        $length = (int) config('registration.otp_length', 6);
        $length = max(4, min(8, $length));

        $min = 10 ** ($length - 1);
        $max = (10 ** $length) - 1;

        return (string) random_int($min, $max);
    }
}
