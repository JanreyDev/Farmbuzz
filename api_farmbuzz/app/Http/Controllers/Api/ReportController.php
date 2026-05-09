<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EggCollection;
use App\Models\Farm;
use App\Models\FlockBatch;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function summary(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request);

        $totalCollections = EggCollection::query()->where('farm_id', $farm->id)->count();
        $totalEggsCollected = (int) EggCollection::query()->where('farm_id', $farm->id)->sum('egg_count');
        $totalIncubating = EggCollection::query()->where('farm_id', $farm->id)->where('status', 'incubating')->count();

        $totalFlockBatches = FlockBatch::query()->where('farm_id', $farm->id)->count();
        $totalBirds = (int) FlockBatch::query()->where('farm_id', $farm->id)->sum('count');
        $teamMembers = TeamMember::query()->where('farm_id', $farm->id)->count();

        $hatchRate = $totalEggsCollected > 0
            ? round(($totalIncubating / max($totalCollections, 1)) * 100, 1)
            : null;

        return response()->json([
            'data' => [
                'farm_name' => $farm->name,
                'collections_count' => $totalCollections,
                'eggs_collected' => $totalEggsCollected,
                'incubating_batches' => $totalIncubating,
                'flock_batches' => $totalFlockBatches,
                'birds_count' => $totalBirds,
                'team_members' => $teamMembers,
                'hatch_rate' => $hatchRate,
            ],
        ]);
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
}
