<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();

        $conversations = Conversation::query()
            ->where('user_one_id', $user->id)
            ->orWhere('user_two_id', $user->id)
            ->with(['userOne', 'userTwo', 'lastMessage'])
            ->orderBy('updated_at', 'desc')
            ->get()
            ->map(function (Conversation $conversation) use ($user) {
                $otherUser = $conversation->user_one_id === $user->id ? $conversation->userTwo : $conversation->userOne;
                return [
                    'id' => $conversation->id,
                    'other_user_name' => $otherUser->name,
                    'other_user_avatar' => $otherUser->avatar_url,
                    'last_message' => $conversation->lastMessage?->content ?? '',
                    'last_message_time' => $conversation->lastMessage?->created_at->toIso8601String() ?? $conversation->updated_at->toIso8601String(),
                    'is_unread' => $conversation->lastMessage && $conversation->lastMessage->sender_id !== $user->id && ! $conversation->lastMessage->is_read,
                ];
            });

        return response()->json(['data' => $conversations]);
    }

    public function messages(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'conversation_id' => ['required', 'integer', 'exists:conversations,id'],
        ]);

        $user = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
        $conversation = Conversation::query()->findOrFail($validated['conversation_id']);

        if ($conversation->user_one_id !== $user->id && $conversation->user_two_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $messages = Message::query()
            ->where('conversation_id', $conversation->id)
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function (Message $message) use ($user) {
                return [
                    'id' => $message->id,
                    'content' => $message->content,
                    'sender_id' => $message->sender_id,
                    'is_me' => $message->sender_id === $user->id,
                    'time' => $message->created_at->toIso8601String(),
                ];
            });

        // Mark all unread messages from the other user as read
        Message::query()
            ->where('conversation_id', $conversation->id)
            ->where('sender_id', '!=', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['data' => $messages]);
    }

    public function startConversation(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'target_name' => ['required', 'string', 'exists:users,name'],
        ]);

        $me = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
        $target = User::query()->where('name', $validated['target_name'])->firstOrFail();

        $user_one_id = min($me->id, $target->id);
        $user_two_id = max($me->id, $target->id);

        $conversation = Conversation::query()->firstOrCreate([
            'user_one_id' => $user_one_id,
            'user_two_id' => $user_two_id,
        ]);

        return response()->json(['data' => ['id' => $conversation->id]]);
    }

    public function send(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'conversation_id' => ['required', 'integer', 'exists:conversations,id'],
            'content' => ['required', 'string'],
        ]);

        $me = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
        $conversation = Conversation::query()->findOrFail($validated['conversation_id']);

        if ($conversation->user_one_id !== $me->id && $conversation->user_two_id !== $me->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $message = Message::create([
            'conversation_id' => $conversation->id,
            'sender_id' => $me->id,
            'content' => $validated['content'],
        ]);

        $conversation->update(['last_message_id' => $message->id]);

        return response()->json(['data' => [
            'id' => $message->id,
            'content' => $message->content,
            'sender_id' => $message->sender_id,
            'is_me' => true,
            'time' => $message->created_at->toIso8601String(),
        ]]);
    }
    public function destroy(Request $request, $id): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $me = User::query()->where('mobile_number', $validated['mobile_number'])->firstOrFail();
        $conversation = Conversation::query()->findOrFail($id);

        if ($conversation->user_one_id !== $me->id && $conversation->user_two_id !== $me->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // The database should handle cascading deletion of messages if foreign keys are set up.
        // Otherwise, we explicitly delete messages first.
        Message::where('conversation_id', $conversation->id)->delete();
        $conversation->delete();

        return response()->json(['message' => 'Conversation deleted successfully.']);
    }
}
