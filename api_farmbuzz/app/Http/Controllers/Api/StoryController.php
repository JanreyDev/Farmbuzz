<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Story;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StoryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $stories = Story::query()
            ->with('user:id,name,avatar_url')
            ->where('created_at', '>=', now()->subDay())
            ->latest()
            ->limit(100)
            ->get();

        return response()->json([
            'data' => $stories->map(fn (Story $story): array => [
                'id' => $story->id,
                'name' => $story->user?->name ?? 'Unknown',
                'avatarUrl' => $story->user?->avatar_url ?? '',
                'imageUrl' => $story->image_url,
                'textContent' => $story->text_content,
                'timeAgo' => optional($story->created_at)?->diffForHumans() ?? 'Just now',
                'createdAt' => optional($story->created_at)?->toISOString(),
            ])->values(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'image' => ['nullable', 'image', 'max:8192'],
            'text_content' => ['nullable', 'string', 'max:5000'],
            'visibility' => ['nullable', 'in:public,followers'],
        ]);

        if (! $request->hasFile('image') && empty($validated['text_content'])) {
            return response()->json([
                'message' => 'Story image or text content is required.',
            ], 422);
        }

        $user = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();

        $imageUrl = null;
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $directory = public_path('uploads/stories');
            if (! is_dir($directory)) {
                mkdir($directory, 0755, true);
            }

            $filename = sprintf('story_%d_%d.%s', $user->id, time(), $file->getClientOriginalExtension());
            $file->move($directory, $filename);
            $imageUrl = url('uploads/stories/' . $filename);
        }

        $story = Story::query()->create([
            'user_id' => $user->id,
            'image_url' => $imageUrl,
            'text_content' => $validated['text_content'] ?? null,
            'visibility' => $validated['visibility'] ?? 'public',
        ]);

        return response()->json([
            'message' => 'Story created successfully.',
            'data' => [
                'id' => $story->id,
                'name' => $user->name,
                'avatarUrl' => $user->avatar_url ?? '',
                'imageUrl' => $story->image_url,
                'textContent' => $story->text_content,
                'timeAgo' => optional($story->created_at)?->diffForHumans() ?? 'Just now',
                'createdAt' => optional($story->created_at)?->toISOString(),
            ],
        ], 201);
    }
}
