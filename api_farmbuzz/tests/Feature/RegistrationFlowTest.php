<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class RegistrationFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_complete_registration_flow(): void
    {
        $start = $this->postJson('/api/auth/register/start', [
            'name' => 'Juan Dela Cruz',
            'referral_code' => 'FARM2026',
            'is_at_least_18' => true,
            'accepted_terms' => true,
        ])->assertCreated();

        $registrationId = $start->json('registration_id');

        $this->postJson('/api/auth/register/send-otp', [
            'registration_id' => $registrationId,
            'mobile_number' => '+639171234567',
        ])->assertOk();

        $this->postJson('/api/auth/register/verify-otp', [
            'registration_id' => $registrationId,
            'otp' => '123456',
        ])->assertOk();

        $this->postJson('/api/auth/register/set-pin', [
            'registration_id' => $registrationId,
            'pin' => '123456',
            'pin_confirmation' => '123456',
        ])->assertOk();

        $user = User::query()->findOrFail($registrationId);

        $this->assertSame('completed', $user->registration_status);
        $this->assertNotNull($user->mobile_verified_at);
        $this->assertTrue(Hash::check('123456', $user->pin));
    }

    public function test_user_cannot_verify_with_wrong_otp(): void
    {
        $user = User::query()->create([
            'name' => 'Test User',
            'is_at_least_18' => true,
            'accepted_terms' => true,
            'registration_status' => 'started',
        ]);

        $this->postJson('/api/auth/register/send-otp', [
            'registration_id' => $user->id,
            'mobile_number' => '+639189876543',
        ])->assertOk();

        $this->postJson('/api/auth/register/verify-otp', [
            'registration_id' => $user->id,
            'otp' => '999999',
        ])->assertStatus(422)
            ->assertJson([
                'message' => 'Invalid OTP.',
            ]);
    }
}
