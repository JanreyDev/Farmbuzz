<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Tests\TestCase;

class ProfileMediaTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_upload_avatar_and_cover_photo(): void
    {
        $user = User::query()->create([
            'name' => 'Janrey',
            'mobile_number' => '+639123456789',
            'registration_status' => 'completed',
        ]);

        $response = $this->post('/api/profile/media', [
            'mobile_number' => $user->mobile_number,
            'avatar' => UploadedFile::fake()->image('avatar.jpg'),
            'cover_photo' => UploadedFile::fake()->image('cover.jpg'),
        ]);

        $response->assertOk()
            ->assertJsonPath('message', 'Profile media updated successfully.')
            ->assertJsonStructure([
                'data' => ['avatar_url', 'cover_photo_url'],
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
        ]);

        $user->refresh();
        $this->assertNotNull($user->avatar_url);
        $this->assertNotNull($user->cover_photo_url);
    }
}