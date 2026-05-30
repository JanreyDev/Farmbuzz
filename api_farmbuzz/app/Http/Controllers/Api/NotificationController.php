<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function counts(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();

        $unreadMessages = Conversation::query()
            ->where(function($query) use ($user) {
                $query->where('user_one_id', $user->id)
                      ->orWhere('user_two_id', $user->id);
            })
            ->whereHas('lastMessage', function($query) use ($user) {
                $query->where('sender_id', '!=', $user->id)
                      ->where('is_read', false);
            })
            ->count();

        $unreadNotifications = Notification::query()
            ->where('user_id', $user->id)
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'data' => [
                'messages' => $unreadMessages,
                'notifications' => $unreadNotifications,
            ]
        ]);
    }
}
