<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::query()
            ->where('mobile_number', $request->string('mobile_number')->toString())
            ->first();

        if (! $user || blank($user->pin) || ! Hash::check($request->string('pin')->toString(), $user->pin)) {
            return response()->json(['message' => 'Invalid mobile number or PIN.'], 422);
        }

        if ($user->registration_status !== 'completed') {
            return response()->json(['message' => 'Account setup is not yet complete.'], 422);
        }

        return response()->json([
            'message' => 'Login successful.',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'mobile_number' => $user->mobile_number,
                'avatar_url' => $this->normalizePublicMediaUrl($user->avatar_url, $request),
                'cover_photo_url' => $this->normalizePublicMediaUrl($user->cover_photo_url, $request),
            ],
        ]);
    }

    private function normalizePublicMediaUrl(?string $value, LoginRequest $request): ?string
    {
        if (! is_string($value)) {
            return null;
        }

        $trimmed = trim($value);
        if ($trimmed === '') {
            return null;
        }

        $path = parse_url($trimmed, PHP_URL_PATH);
        if (is_string($path) && str_starts_with($path, '/uploads/')) {
            return rtrim($request->getSchemeAndHttpHost(), '/') . $path;
        }

        if (str_starts_with($trimmed, '/uploads/')) {
            return rtrim($request->getSchemeAndHttpHost(), '/') . $trimmed;
        }

        return $trimmed;
    }
}
