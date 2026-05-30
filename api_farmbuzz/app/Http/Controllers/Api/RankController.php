<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\ReputationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RankController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        $reputationService = app(ReputationService::class);
        $xp = $user->xp ?? 0;
        
        $progress = $reputationService->getProgress($xp);

        // Calculate "Activity this month" - basic for now
        $postsThisMonth = \App\Models\Post::where('author_name', $user->name)
            ->where('created_at', '>=', now()->subDays(30))
            ->count();
        $activity = 'Quiet';
        if ($postsThisMonth > 10) {
            $activity = 'Very Active';
        } elseif ($postsThisMonth > 3) {
            $activity = 'Active';
        }

        return response()->json([
            'data' => [
                'xp' => $xp,
                'current_rank' => $progress['current_rank'],
                'next_rank' => $progress['next_rank'],
                'progress_percentage' => $progress['progress_percentage'],
                'member_since' => $user->created_at->format('M Y'),
                'activity_level' => $activity,
                'region' => 'the Philippines', // Could come from farm/profile later
            ]
        ]);
    }
}
