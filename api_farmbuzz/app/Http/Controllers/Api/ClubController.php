<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Club;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ClubController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        $clubs = Club::query()
            ->where('user_id', $user->id)
            ->latest()
            ->get();

        return response()->json([
            'data' => $clubs->map(fn (Club $club): array => $this->clubPayload($club, true))->values(),
        ]);
    }

    public function uploadCover(Request $request): JsonResponse
    {
        $request->validate([
            'cover' => ['required', 'image', 'max:5120'], // 5 MB
        ]);

        $file = $request->file('cover');
        $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
        $file->move(public_path('uploads/clubs'), $filename);

        $url = url('uploads/clubs/' . $filename);

        return response()->json(['url' => $url]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:4000'],
            'category' => ['nullable', 'string', 'max:100'],
            'region' => ['nullable', 'string', 'max:100'],
            'focus_tags' => ['nullable', 'array'],
            'focus_tags.*' => ['string', 'max:100'],
            'is_public' => ['nullable', 'boolean'],
            'min_birds' => ['nullable', 'integer', 'min:0'],
            'verified_only' => ['nullable', 'boolean'],
            'cover_image_url' => ['nullable', 'string', 'max:2048'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        $club = Club::query()->create([
            'user_id' => $user->id,
            'name' => trim((string) $validated['name']),
            'description' => isset($validated['description']) ? trim((string) $validated['description']) : null,
            'category' => $validated['category'] ?? 'Community',
            'region' => isset($validated['region']) ? trim((string) $validated['region']) : null,
            'focus_tags' => $validated['focus_tags'] ?? [],
            'is_public' => $validated['is_public'] ?? true,
            'min_birds' => $validated['min_birds'] ?? 0,
            'verified_only' => $validated['verified_only'] ?? false,
            'cover_image_url' => isset($validated['cover_image_url']) ? trim((string) $validated['cover_image_url']) : null,
            'member_count' => 1,
            'post_count' => 0,
        ]);

        return response()->json([
            'message' => 'Club created successfully.',
            'data' => $this->clubPayload($club, true),
        ], 201);
    }

    public function discover(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['nullable', 'string', 'exists:users,mobile_number'],
            'category' => ['nullable', 'string', 'max:100'],
        ]);

        $excludeUserId = null;
        if (! empty($validated['mobile_number'])) {
            $excludeUserId = User::query()
                ->where('mobile_number', $validated['mobile_number'])
                ->value('id');
        }

        $query = Club::query()
            ->where('is_public', true)
            ->latest();

        if ($excludeUserId !== null) {
            $query->where('user_id', '!=', $excludeUserId);
        }

        if (! empty($validated['category']) && $validated['category'] !== 'All') {
            $query->where('category', $validated['category']);
        }

        $clubs = $query->limit(50)->get();

        return response()->json([
            'data' => $clubs->map(fn (Club $club): array => $this->clubPayload($club, false))->values(),
        ]);
    }

    private function clubPayload(Club $club, bool $isOwner): array
    {
        return [
            'id' => $club->id,
            'title' => $club->name,
            'description' => $club->description,
            'category' => $club->category,
            'region' => $club->region,
            'focus_tags' => $club->focus_tags ?? [],
            'is_public' => $club->is_public,
            'min_birds' => $club->min_birds,
            'verified_only' => $club->verified_only,
            'imageUrl' => $club->cover_image_url,
            'memberCount' => $club->member_count,
            'postCount' => $club->post_count,
            'role' => $isOwner ? 'founder' : 'member',
        ];
    }
}
