<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Farm;
use App\Models\FlockBatch;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FlockController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        $items = FlockBatch::query()
            ->where('farm_id', $farm->id)
            ->latest()
            ->get();

        return response()->json([
            'data' => $items->map(fn (FlockBatch $item): array => $this->payload($item))->values(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'category' => ['nullable', 'in:batch,rooster,hen'],
            'stage' => ['nullable', 'in:brooder,range,archive'],
            'count' => ['required', 'integer', 'min:0'],
            'started_on' => ['required', 'date_format:Y-m-d'],
            'note' => ['nullable', 'string', 'max:255'],
        ]);

        $item = FlockBatch::query()->create([
            'farm_id' => $farm->id,
            'name' => trim((string) $validated['name']),
            'category' => $validated['category'] ?? 'batch',
            'stage' => $validated['stage'] ?? 'brooder',
            'count' => $validated['count'],
            'started_on' => $validated['started_on'],
            'note' => isset($validated['note']) ? trim((string) $validated['note']) : null,
        ]);

        return response()->json([
            'message' => 'Flock batch created successfully.',
            'data' => $this->payload($item),
        ], 201);
    }

    public function destroy(Request $request, FlockBatch $flockBatch): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        if ($flockBatch->farm_id !== $farm->id) {
            return response()->json(['message' => 'Flock batch not found for this farm.'], 404);
        }

        $flockBatch->delete();

        return response()->json(['message' => 'Flock batch deleted successfully.']);
    }

    private function resolveFarmForMobile(Request $request): Farm
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
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

    private function payload(FlockBatch $item): array
    {
        return [
            'id' => $item->id,
            'name' => $item->name,
            'category' => $item->category,
            'stage' => $item->stage,
            'count' => $item->count,
            'started_on' => $item->started_on,
            'note' => $item->note,
            'created_at' => optional($item->created_at)?->toISOString(),
        ];
    }
}
