<?php

namespace Tests\Feature;

use App\Models\Post;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PostFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_post(): void
    {
        $response = $this->postJson('/api/posts', [
            'author_name' => 'Janrey',
            'author_avatar' => 'https://i.pravatar.cc/150?u=janrey',
            'content' => 'My first real post',
            'image_paths' => [],
        ]);

        $response->assertCreated()
            ->assertJsonPath('message', 'Post created successfully.')
            ->assertJsonPath('data.userName', 'Janrey')
            ->assertJsonPath('data.postText', 'My first real post');

        $this->assertDatabaseHas('posts', [
            'author_name' => 'Janrey',
            'content' => 'My first real post',
        ]);
    }

    public function test_user_can_get_posts(): void
    {
        Post::query()->create([
            'author_name' => 'Janrey',
            'author_avatar' => 'https://i.pravatar.cc/150?u=janrey',
            'content' => 'Newest post',
            'image_paths' => [],
            'published_at' => now(),
        ]);

        $response = $this->getJson('/api/posts');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    [
                        'id',
                        'userName',
                        'userAvatar',
                        'timeAgo',
                        'postText',
                        'postImageUrl',
                        'localImagePaths',
                        'likesCount',
                        'commentsCount',
                    ],
                ],
            ]);
    }
}
