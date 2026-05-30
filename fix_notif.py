import sys

def modify(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove the broken methods
    content = content.split("    public function index(Request ): JsonResponse")[0]

    new_methods = '''    public function index(Request ): JsonResponse
    {
         = ->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

         = User::query()->where('mobile_number', ['mobile_number'])->firstOrFail();

         = Notification::query()
            ->where('user_id', ->id)
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get();

        return response()->json(['data' => ]);
    }

    public function markAsRead(Request ): JsonResponse
    {
         = ->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

         = User::query()->where('mobile_number', ['mobile_number'])->firstOrFail();

        Notification::query()
            ->where('user_id', ->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['message' => 'Notifications marked as read']);
    }
}'''

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content + new_methods)

modify('api_farmbuzz/app/Http/Controllers/Api/NotificationController.php')