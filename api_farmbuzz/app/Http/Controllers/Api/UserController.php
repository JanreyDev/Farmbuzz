<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BlockedUser;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function search(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'q' => ['nullable', 'string', 'max:255'],
        ]);

        $query = $validated['q'] ?? '';

        if (empty($query)) {
            return response()->json(['data' => []]);
        }

        $users = User::query()
            ->where('name', 'LIKE', '%' . $query . '%')
            ->orderBy('name', 'asc')
            ->limit(20)
            ->get(['id', 'name', 'avatar_url', 'mobile_number']);

        return response()->json(['data' => $users]);
    }

    // POST /users/block
    public function block(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'blocker_name' => ['required', 'string', 'max:255'],
            'blocked_name'  => ['required', 'string', 'max:255'],
        ]);

        if (strtolower($validated['blocker_name']) === strtolower($validated['blocked_name'])) {
            return response()->json(['message' => 'You cannot block yourself.'], 422);
        }

        BlockedUser::firstOrCreate([
            'blocker_name' => $validated['blocker_name'],
            'blocked_name'  => $validated['blocked_name'],
        ]);

        return response()->json(['message' => 'User blocked successfully.']);
    }

    // DELETE /users/block
    public function unblock(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'blocker_name' => ['required', 'string', 'max:255'],
            'blocked_name'  => ['required', 'string', 'max:255'],
        ]);

        BlockedUser::where('blocker_name', $validated['blocker_name'])
            ->where('blocked_name', $validated['blocked_name'])
            ->delete();

        return response()->json(['message' => 'User unblocked successfully.']);
    }

    // GET /users/blocked?blocker_name=xxx
    public function blocked(Request $request): JsonResponse
    {
        $blockerName = trim((string) $request->query('blocker_name', ''));

        if ($blockerName === '') {
            return response()->json(['data' => []]);
        }

        $blocked = BlockedUser::where('blocker_name', $blockerName)
            ->pluck('blocked_name')
            ->values()
            ->all();

        return response()->json(['data' => $blocked]);
    }
}