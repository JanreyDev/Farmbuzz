<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Comment;
use App\Models\Post;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'mobile_number' => $user->mobile_number,
                'avatar_url' => $user->avatar_url,
                'cover_photo_url' => $user->cover_photo_url,
            ],
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'name' => ['required', 'string', 'max:255'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        $oldName = $user->name;
        $newName = trim((string) $validated['name']);

        $user->name = $newName;
        $user->save();

        if ($oldName !== $newName) {
            Post::query()
                ->where('author_name', $oldName)
                ->update(['author_name' => $newName]);

            Comment::query()
                ->where('author_name', $oldName)
                ->update(['author_name' => $newName]);
        }

        return response()->json([
            'message' => 'Profile updated successfully.',
            'data' => [
                'name' => $user->name,
                'mobile_number' => $user->mobile_number,
                'avatar_url' => $user->avatar_url,
                'cover_photo_url' => $user->cover_photo_url,
            ],
        ]);
    }

    public function updateMedia(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'avatar' => ['nullable', 'image', 'max:5120'],
            'cover_photo' => ['nullable', 'image', 'max:5120'],
        ]);

        if (! $request->hasFile('avatar') && ! $request->hasFile('cover_photo')) {
            return response()->json([
                'message' => 'Please attach avatar or cover photo.',
            ], 422);
        }

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        if ($request->hasFile('avatar')) {
            $this->deleteLocalUploadIfPresent($user->avatar_url);
            $user->avatar_url = $this->storePublicUpload($request->file('avatar'), 'avatar');
        }

        if ($request->hasFile('cover_photo')) {
            $this->deleteLocalUploadIfPresent($user->cover_photo_url);
            $user->cover_photo_url = $this->storePublicUpload($request->file('cover_photo'), 'cover');
        }

        $user->save();

        if ($request->hasFile('avatar')) {
            Post::query()
                ->where('author_name', $user->name)
                ->update(['author_avatar' => $user->avatar_url]);

            Comment::query()
                ->where('author_name', $user->name)
                ->update(['author_avatar' => $user->avatar_url]);
        }

        return response()->json([
            'message' => 'Profile media updated successfully.',
            'data' => [
                'avatar_url' => $user->avatar_url,
                'cover_photo_url' => $user->cover_photo_url,
            ],
        ]);
    }

    private function storePublicUpload(UploadedFile $file, string $prefix): string
    {
        $directory = public_path('uploads/profile');
        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $filename = sprintf(
            '%s_%s.%s',
            $prefix,
            now()->format('YmdHisv'),
            $file->getClientOriginalExtension(),
        );

        $file->move($directory, $filename);

        return url('uploads/profile/' . $filename);
    }

    private function deleteLocalUploadIfPresent(?string $absoluteUrl): void
    {
        if (! is_string($absoluteUrl) || $absoluteUrl === '') {
            return;
        }

        $path = parse_url($absoluteUrl, PHP_URL_PATH);
        if (! is_string($path) || ! str_starts_with($path, '/uploads/profile/')) {
            return;
        }

        $filePath = public_path(ltrim($path, '/'));
        if (File::exists($filePath)) {
            File::delete($filePath);
        }
    }
}