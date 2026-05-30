<?php

namespace App\Services;

use App\Models\User;
use App\Models\XpLog;
use Illuminate\Support\Carbon;

class ReputationService
{
    // Action types and their corresponding XP
    const ACTION_POST = 'post';
    const ACTION_STORY = 'story';
    const ACTION_CLUB_JOIN = 'club_join';
    const ACTION_PHOTO_UPLOAD = 'photo_upload';

    const XP_MAP = [
        self::ACTION_POST => 20,
        self::ACTION_STORY => 15,
        self::ACTION_CLUB_JOIN => 15,
        self::ACTION_PHOTO_UPLOAD => 10,
    ];

    const CAP_MAP = [
        self::ACTION_POST => 5, // max 5 per day
        self::ACTION_STORY => 3, // max 3 per day
        self::ACTION_CLUB_JOIN => 1, // max 1 per club (handled differently)
        self::ACTION_PHOTO_UPLOAD => 3, // max 3 per day
    ];

    /**
     * Award XP to a user if they haven't hit the cap.
     */
    public function awardXp(User $user, string $actionType, ?string $referenceId = null): void
    {
        if (!isset(self::XP_MAP[$actionType])) {
            return; // Invalid action
        }

        $xpToAward = self::XP_MAP[$actionType];
        $cap = self::CAP_MAP[$actionType];

        // For actions like club_join, cap is once per referenceId (the club id)
        if ($actionType === self::ACTION_CLUB_JOIN && $referenceId) {
            $alreadyAwarded = XpLog::where('user_id', $user->id)
                ->where('action_type', $actionType)
                ->where('reference_id', $referenceId)
                ->exists();

            if ($alreadyAwarded) {
                return;
            }
        } else {
            // For other actions, enforce a daily cap
            $todayCount = XpLog::where('user_id', $user->id)
                ->where('action_type', $actionType)
                ->whereDate('created_at', Carbon::today())
                ->count();

            if ($todayCount >= $cap) {
                return;
            }
        }

        // Award the XP
        XpLog::create([
            'user_id' => $user->id,
            'action_type' => $actionType,
            'xp_awarded' => $xpToAward,
            'reference_id' => $referenceId,
        ]);

        $user->increment('xp', $xpToAward);
    }

    /**
     * Calculate rank based on XP.
     */
    public function calculateRank(int $xp): string
    {
        if ($xp >= 2000) {
            return 'Gold'; // Plus maybe years requirement? Keeping simple for now
        }
        if ($xp >= 1000) {
            return 'Silver';
        }
        if ($xp >= 200) {
            return 'Iron';
        }
        return 'Bronze';
    }

    /**
     * Calculate progress to next rank.
     * Returns an array with current rank, next rank, and percentage (0-100).
     */
    public function getProgress(int $xp): array
    {
        $tiers = [
            ['rank' => 'Bronze', 'min' => 0, 'max' => 200],
            ['rank' => 'Iron', 'min' => 200, 'max' => 1000],
            ['rank' => 'Silver', 'min' => 1000, 'max' => 2000],
            ['rank' => 'Gold', 'min' => 2000, 'max' => 999999],
        ];

        $currentTier = $tiers[0];
        $nextTier = $tiers[1];

        for ($i = 0; $i < count($tiers); $i++) {
            if ($xp >= $tiers[$i]['min'] && $xp < $tiers[$i]['max']) {
                $currentTier = $tiers[$i];
                if ($i + 1 < count($tiers)) {
                    $nextTier = $tiers[$i + 1];
                } else {
                    $nextTier = null; // Max rank reached
                }
                break;
            }
        }

        if (!$nextTier) {
            return [
                'current_rank' => $currentTier['rank'],
                'next_rank' => null,
                'progress_percentage' => 100,
            ];
        }

        $tierRange = $currentTier['max'] - $currentTier['min'];
        $xpInTier = $xp - $currentTier['min'];
        $percentage = (int) round(($xpInTier / $tierRange) * 100);

        return [
            'current_rank' => $currentTier['rank'],
            'next_rank' => $nextTier['rank'],
            'progress_percentage' => $percentage,
        ];
    }
}
