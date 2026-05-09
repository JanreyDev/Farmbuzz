<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Farm;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FarmController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

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
            return response()->json([
                'message' => 'Farm not found.',
                'data' => null,
            ]);
        }

        return response()->json([
            'data' => $this->farmPayload($farm, $user),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'name' => ['required', 'string', 'max:255'],
            'farm_type' => ['nullable', 'string', 'max:255'],
            'city' => ['nullable', 'string', 'max:255'],
            'started_year' => ['nullable', 'integer', 'between:1900,2200'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        $farm = Farm::query()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'name' => trim((string) $validated['name']),
                'farm_type' => $validated['farm_type'] ?? null,
                'city' => $validated['city'] ?? null,
                'started_year' => $validated['started_year'] ?? null,
            ],
        );

        return response()->json([
            'message' => 'Farm saved successfully.',
            'data' => $this->farmPayload($farm, $user),
        ], 201);
    }

    public function destroy(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        Farm::query()
            ->where('user_id', $user->id)
            ->delete();

        return response()->json([
            'message' => 'Farm deleted successfully.',
        ]);
    }

    private function farmPayload(Farm $farm, User $user): array
    {
        return [
            'id' => $farm->id,
            'name' => $farm->name,
            'farm_type' => $farm->farm_type,
            'city' => $farm->city,
            'started_year' => $farm->started_year,
            'birds_count' => $farm->birds_count,
            'active_cycles' => $farm->active_cycles,
            'eggs_incubating' => $farm->eggs_incubating,
            'owner_name' => $user->name,
        ];
    }
}
