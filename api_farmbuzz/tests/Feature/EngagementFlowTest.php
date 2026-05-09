<?php

namespace Tests\Feature;

use App\Models\Post;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EngagementFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_like_and_unlike_post(): void
    {
        $post = Post::query()->create([
            'author_name' => 'Janrey',
            'content' => 'Like me',
            'image_paths' => [],
            'published_at' => now(),
        ]);

        $this->postJson("/api/posts/{$post->id}/like", [
            'reactor_name' => 'Janrey',
            'reaction' => '❤️',
        ])
            ->assertOk()
            ->assertJsonPath('likesCount', '1')
            ->assertJsonPath('userReaction', '❤️');

        $this->postJson("/api/posts/{$post->id}/unlike", [
            'reactor_name' => 'Janrey',
        ])
            ->assertOk()
            ->assertJsonPath('likesCount', '0');
    }

    public function test_user_can_add_comment_and_fetch_comments(): void
    {
        $post = Post::query()->create([
            'author_name' => 'Janrey',
            'content' => 'Comment me',
            'image_paths' => [],
            'published_at' => now(),
        ]);

        $this->postJson("/api/posts/{$post->id}/comments", [
            'author_name' => 'Alyssa',
            'author_avatar' => 'https://i.pravatar.cc/150?u=alyssa',
            'content' => 'Great post!',
        ])->assertCreated()
            ->assertJsonPath('commentsCount', '1');

        $this->getJson("/api/posts/{$post->id}/comments")
            ->assertOk()
            ->assertJsonPath('commentsCount', '1')
            ->assertJsonPath('data.0.name', 'Alyssa')
            ->assertJsonPath('data.0.text', 'Great post!');
    }

    public function test_user_reaction_persists_on_posts_index(): void
    {
        $post = Post::query()->create([
            'author_name' => 'Janrey',
            'content' => 'Reaction persistence test',
            'image_paths' => [],
            'published_at' => now(),
        ]);

        $this->postJson("/api/posts/{$post->id}/like", [
            'reactor_name' => 'Janrey',
            'reaction' => '❤️',
        ])->assertOk();

        $this->getJson('/api/posts?reactor_name=Janrey')
            ->assertOk()
            ->assertJsonPath('data.0.userReaction', '❤️');
    }
}
