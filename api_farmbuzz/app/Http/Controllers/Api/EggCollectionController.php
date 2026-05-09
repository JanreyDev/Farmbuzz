<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EggCollection;
use App\Models\Farm;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EggCollectionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        $collections = EggCollection::query()
            ->where('farm_id', $farm->id)
            ->orderByDesc('collected_on')
            ->orderByDesc('id')
            ->get();

        return response()->json([
            'data' => $collections->map(fn (EggCollection $item): array => $this->payload($item))->values(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        $validated = $request->validate([
            'batch_name' => ['required', 'string', 'max:255'],
            'egg_count' => ['required', 'integer', 'min:1'],
            'collected_on' => ['required', 'date_format:Y-m-d'],
            'note' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:30'],
        ]);

        $collection = EggCollection::query()->create([
            'farm_id' => $farm->id,
            'batch_name' => trim((string) $validated['batch_name']),
            'egg_count' => $validated['egg_count'],
            'collected_on' => $validated['collected_on'],
            'note' => isset($validated['note']) ? trim((string) $validated['note']) : null,
            'status' => $validated['status'] ?? 'fresh',
        ]);

        return response()->json([
            'message' => 'Collection saved successfully.',
            'data' => $this->payload($collection),
        ], 201);
    }

    public function update(Request $request, EggCollection $eggCollection): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        if ($eggCollection->farm_id !== $farm->id) {
            return response()->json([
                'message' => 'Collection record not found for this farm.',
            ], 404);
        }

        $validated = $request->validate([
            'batch_name' => ['required', 'string', 'max:255'],
            'egg_count' => ['required', 'integer', 'min:1'],
            'collected_on' => ['required', 'date_format:Y-m-d'],
            'note' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:30'],
        ]);

        $eggCollection->update([
            'batch_name' => trim((string) $validated['batch_name']),
            'egg_count' => $validated['egg_count'],
            'collected_on' => $validated['collected_on'],
            'note' => isset($validated['note']) ? trim((string) $validated['note']) : null,
            'status' => $validated['status'] ?? 'fresh',
        ]);

        return response()->json([
            'message' => 'Collection updated successfully.',
            'data' => $this->payload($eggCollection->fresh()),
        ]);
    }

    public function destroy(Request $request, EggCollection $eggCollection): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        if ($eggCollection->farm_id !== $farm->id) {
            return response()->json([
                'message' => 'Collection record not found for this farm.',
            ], 404);
        }

        $eggCollection->delete();

        return response()->json([
            'message' => 'Collection deleted successfully.',
        ]);
    }

    private function resolveFarmForMobile(Request $request): Farm
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
            throw new HttpResponseException(response()->json([
                'message' => 'Farm not found for this user.',
            ], 404));
        }

        return $farm;
    }

    private function payload(EggCollection $item): array
    {
        return [
            'id' => $item->id,
            'batch_name' => $item->batch_name,
            'egg_count' => $item->egg_count,
            'collected_on' => $item->collected_on,
            'note' => $item->note,
            'status' => $item->status,
            'created_at' => optional($item->created_at)?->toISOString(),
        ];
    }
}
