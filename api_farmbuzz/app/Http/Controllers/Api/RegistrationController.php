<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\SendOtpRequest;
use App\Http\Requests\Auth\SetPinRequest;
use App\Http\Requests\Auth\StartRegistrationRequest;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

class RegistrationController extends Controller
{
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

        $user->forceFill([
            'mobile_number' => $request->string('mobile_number')->toString(),
            'otp_code' => Hash::make((string) config('registration.default_otp', '123456')),
            'otp_sent_at' => now(),
            'mobile_verified_at' => null,
            'registration_status' => 'otp_sent',
        ])->save();

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
}
