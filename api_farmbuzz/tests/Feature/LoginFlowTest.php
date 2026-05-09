<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class LoginFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_login_with_valid_mobile_and_pin(): void
    {
        $user = User::query()->create([
            'name' => 'Juan Dela Cruz',
            'mobile_number' => '+639171234567',
            'pin' => Hash::make('123456'),
            'is_at_least_18' => true,
            'accepted_terms' => true,
            'registration_status' => 'completed',
            'mobile_verified_at' => now(),
            'registration_completed_at' => now(),
        ]);

        $this->postJson('/api/auth/login', [
            'mobile_number' => '+639171234567',
            'pin' => '123456',
        ])->assertOk()
            ->assertJson([
                'message' => 'Login successful.',
                'user' => [
                    'id' => $user->id,
                    'name' => 'Juan Dela Cruz',
                    'mobile_number' => '+639171234567',
                ],
            ]);
    }

    public function test_user_cannot_login_with_invalid_pin(): void
    {
        User::query()->create([
            'name' => 'Test User',
            'mobile_number' => '+639189876543',
            'pin' => Hash::make('123456'),
            'is_at_least_18' => true,
            'accepted_terms' => true,
            'registration_status' => 'completed',
            'mobile_verified_at' => now(),
            'registration_completed_at' => now(),
        ]);

        $this->postJson('/api/auth/login', [
            'mobile_number' => '+639189876543',
            'pin' => '999999',
        ])->assertStatus(422)
            ->assertJson([
                'message' => 'Invalid mobile number or PIN.',
            ]);
    }
}
