<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Farm;
use App\Models\SocialConnection;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function inviteCandidates(Request $request): JsonResponse
    {
        $owner = $this->resolveUserByMobile($request, 'mobile_number');

        $candidateIds = SocialConnection::query()
            ->where('owner_user_id', $owner->id)
            ->whereIn('relation', ['friend', 'follower', 'following'])
            ->pluck('target_user_id')
            ->unique()
            ->values();

        $users = User::query()
            ->whereIn('id', $candidateIds)
            ->get(['id', 'name', 'mobile_number', 'avatar_url']);

        return response()->json([
            'data' => $users->map(fn (User $user): array => [
                'id' => $user->id,
                'name' => $user->name,
                'mobile_number' => $user->mobile_number,
                'avatar_url' => $user->avatar_url,
            ])->values(),
        ]);
    }

    public function index(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        $items = TeamMember::query()
            ->where('farm_id', $farm->id)
            ->latest()
            ->get();

        return response()->json([
            'data' => $items->map(fn (TeamMember $item): array => $this->payload($item))->values(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $owner = $this->resolveUserByMobile($request, 'owner_mobile_number');
        $farm = $this->resolveFarmForUser($owner);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'mobile_number' => ['required', 'string', 'max:20'],
            'role' => ['nullable', 'string', 'max:40'],
            'status' => ['nullable', 'in:active,inactive'],
        ]);

        $invitee = User::query()
            ->where('mobile_number', trim((string) $validated['mobile_number']))
            ->first();

        if (! $invitee) {
            return response()->json(['message' => 'Invitee account not found.'], 422);
        }

        $isConnected = SocialConnection::query()
            ->where('owner_user_id', $owner->id)
            ->where('target_user_id', $invitee->id)
            ->whereIn('relation', ['friend', 'follower', 'following'])
            ->exists();

        if (! $isConnected) {
            return response()->json([
                'message' => 'You can only invite users from your friends, followers, or following list.',
            ], 422);
        }

        $item = TeamMember::query()->updateOrCreate(
            [
                'farm_id' => $farm->id,
                'mobile_number' => trim((string) $validated['mobile_number']),
            ],
            [
                'name' => trim((string) $validated['name']),
                'role' => $validated['role'] ?? 'caretaker',
                'status' => $validated['status'] ?? 'active',
            ],
        );

        return response()->json([
            'message' => 'Team member saved successfully.',
            'data' => $this->payload($item),
        ], 201);
    }

    public function destroy(Request $request, TeamMember $teamMember): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request, 'owner_mobile_number');

        if ($teamMember->farm_id !== $farm->id) {
            return response()->json(['message' => 'Team member not found for this farm.'], 404);
        }

        $teamMember->delete();

        return response()->json(['message' => 'Team member deleted successfully.']);
    }

    private function resolveFarmForMobile(Request $request, string $field = 'mobile_number'): Farm
    {
        $user = $this->resolveUserByMobile($request, $field);
        return $this->resolveFarmForUser($user);
    }

    private function resolveUserByMobile(Request $request, string $field): User
    {
        $validated = $request->validate([
            $field => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        return User::query()->where('mobile_number', $validated[$field])->firstOrFail();
    }

    private function resolveFarmForUser(User $user): Farm
    {
        $farm = Farm::query()->where('user_id', $user->id)->first();
        if (! $farm) {
            $teamFarmId = TeamMember::query()
                ->where('mobile_number', $user->mobile_number)
                ->latest('id')
                ->value('farm_id');

            if ($teamFarmId) {
                $farm = Farm::query()->find($teamFarmId);
            }
        }

        if (! $farm) {
            throw new HttpResponseException(response()->json(['message' => 'Farm not found for this user.'], 404));
        }

        return $farm;
    }

    private function payload(TeamMember $item): array
    {
        return [
            'id' => $item->id,
            'name' => $item->name,
            'mobile_number' => $item->mobile_number,
            'role' => $item->role,
            'status' => $item->status,
            'created_at' => optional($item->created_at)?->toISOString(),
        ];
    }
}
