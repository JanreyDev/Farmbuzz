<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SocialConnection;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SocialController extends Controller
{
    public function status(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'target_name' => ['required', 'string', 'max:255'],
        ]);

        $owner = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
        $target = User::query()->where('name', $validated['target_name'])->first();

        if (! $target) {
            return response()->json(['data' => [
                'is_owner' => false,
                'is_following' => false,
                'followers_count' => 0,
                'following_count' => 0,
            ]]);
        }

        $isOwner = $owner->id === $target->id;
        $isFollowing = false;
        $followersCount = (int) SocialConnection::query()
            ->where('target_user_id', $target->id)
            ->where('relation', 'following')
            ->count();
        $followingCount = (int) SocialConnection::query()
            ->where('owner_user_id', $target->id)
            ->where('relation', 'following')
            ->count();

        if (! $isOwner) {
            $isFollowing = SocialConnection::query()
                ->where('owner_user_id', $owner->id)
                ->where('target_user_id', $target->id)
                ->where('relation', 'following')
                ->exists();
        }

        return response()->json([
            'data' => [
                'is_owner' => $isOwner,
                'is_following' => $isFollowing,
                'followers_count' => $followersCount,
                'following_count' => $followingCount,
            ],
        ]);
    }

    public function counts(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'target_name' => ['nullable', 'string', 'max:255'],
        ]);

        $owner = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
        $target = $owner;
        if (! empty($validated['target_name'])) {
            $target = User::query()->where('name', $validated['target_name'])->first() ?? $owner;
        }

        $followersCount = (int) SocialConnection::query()
            ->where('target_user_id', $target->id)
            ->where('relation', 'following')
            ->count();
        $followingCount = (int) SocialConnection::query()
            ->where('owner_user_id', $target->id)
            ->where('relation', 'following')
            ->count();

        return response()->json([
            'data' => [
                'followers_count' => $followersCount,
                'following_count' => $followingCount,
            ],
        ]);
    }

    public function follow(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'target_name' => ['required', 'string', 'max:255'],
        ]);

        $owner = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
        $target = User::query()->where('name', $validated['target_name'])->first();

        if (! $target) {
            return response()->json(['message' => 'Target user not found.'], 404);
        }
        if ($owner->id === $target->id) {
            return response()->json(['message' => 'Cannot follow your own profile.'], 422);
        }

        SocialConnection::query()->firstOrCreate([
            'owner_user_id' => $owner->id,
            'target_user_id' => $target->id,
            'relation' => 'following',
        ]);

        return response()->json(['message' => 'Followed successfully.']);
    }

    public function unfollow(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'target_name' => ['required', 'string', 'max:255'],
        ]);

        $owner = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
        $target = User::query()->where('name', $validated['target_name'])->first();

        if (! $target) {
            return response()->json(['message' => 'Target user not found.'], 404);
        }

        SocialConnection::query()
            ->where('owner_user_id', $owner->id)
            ->where('target_user_id', $target->id)
            ->where('relation', 'following')
            ->delete();

        return response()->json(['message' => 'Unfollowed successfully.']);
    }
}
