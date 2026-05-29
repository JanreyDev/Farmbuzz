<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Farm;
use App\Models\HeritageLine;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HeritageLineController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request, true);
        if (! $farm) {
            return response()->json([
                'message' => 'Farm not found.',
                'data' => [],
            ]);
        }

        $lines = HeritageLine::query()
            ->where('farm_id', $farm->id)
            ->latest('id')
            ->get()
            ->map(fn (HeritageLine $line): array => $this->payload($line))
            ->values();

        return response()->json(['data' => $lines]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'name' => ['required', 'string', 'max:120'],
            'description' => ['nullable', 'string', 'max:500'],
        ]);

        $farm = $this->resolveFarmForMobile($request);
        if (! $farm) {
            return response()->json(['message' => 'Farm not found.'], 404);
        }

        $line = HeritageLine::query()->create([
            'farm_id' => $farm->id,
            'name' => trim((string) $validated['name']),
            'description' => isset($validated['description']) ? trim((string) $validated['description']) : null,
        ]);

        return response()->json([
            'message' => 'Heritage line added successfully.',
            'data' => $this->payload($line),
        ], 201);
    }

    public function update(Request $request, HeritageLine $heritageLine): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'name' => ['required', 'string', 'max:120'],
            'description' => ['nullable', 'string', 'max:500'],
        ]);

        $farm = $this->resolveFarmForMobile($request);
        if (! $farm || $heritageLine->farm_id !== $farm->id) {
            return response()->json(['message' => 'Heritage line not found.'], 404);
        }

        $heritageLine->name = trim((string) $validated['name']);
        $heritageLine->description = isset($validated['description']) ? trim((string) $validated['description']) : null;
        $heritageLine->save();

        return response()->json([
            'message' => 'Heritage line updated successfully.',
            'data' => $this->payload($heritageLine),
        ]);
    }

    public function destroy(Request $request, HeritageLine $heritageLine): JsonResponse
    {
        $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $farm = $this->resolveFarmForMobile($request);
        if (! $farm || $heritageLine->farm_id !== $farm->id) {
            return response()->json(['message' => 'Heritage line not found.'], 404);
        }

        $heritageLine->delete();

        return response()->json([
            'message' => 'Heritage line deleted successfully.',
        ]);
    }

    private function payload(HeritageLine $line): array
    {
        return [
            'id' => $line->id,
            'name' => $line->name,
            'description' => $line->description ?? '',
            'created_at' => optional($line->created_at)?->toIso8601String() ?? '',
        ];
    }

    private function resolveFarmForMobile(Request $request, bool $allowNull = false): ?Farm
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

        if (! $farm && ! $allowNull) {
            return null;
        }

        return $farm;
    }
}

