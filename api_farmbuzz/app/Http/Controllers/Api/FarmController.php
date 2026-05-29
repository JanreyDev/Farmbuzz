<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Farm;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;

class FarmController extends Controller
{
    public function show(Request $request): JsonResponse
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
            return response()->json([
                'message' => 'Farm not found.',
                'data' => null,
            ]);
        }

        return response()->json([
            'data' => $this->farmPayload($farm, $user, $request),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'name'          => ['required', 'string', 'max:255'],
            'tagline'       => ['nullable', 'string', 'max:160'],
            'farm_type'     => ['nullable', 'string', 'max:255'],
            'city'          => ['nullable', 'string', 'max:255'],
            'province'      => ['nullable', 'string', 'max:255'],
            'started_year'  => ['nullable', 'integer', 'between:1900,2200'],
            'story'         => ['nullable', 'string'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        $farm = Farm::query()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'name'         => trim((string) $validated['name']),
                'tagline'      => $validated['tagline'] ?? null,
                'farm_type'    => $validated['farm_type'] ?? null,
                'city'         => $validated['city'] ?? null,
                'province'     => $validated['province'] ?? null,
                'started_year' => $validated['started_year'] ?? null,
                'story'        => $validated['story'] ?? null,
            ],
        );

        return response()->json([
            'message' => 'Farm saved successfully.',
            'data'    => $this->farmPayload($farm, $user, $request),
        ], 201);
    }

    public function updateMedia(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'avatar'        => ['nullable', 'image', 'max:5120'],
            'cover_photo'   => ['nullable', 'image', 'max:5120'],
        ]);

        if (! $request->hasFile('avatar') && ! $request->hasFile('cover_photo')) {
            return response()->json([
                'message' => 'Please attach avatar or cover photo.',
            ], 422);
        }

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        $farm = Farm::query()->where('user_id', $user->id)->first();
        if (! $farm) {
            return response()->json(['message' => 'Farm not found.'], 404);
        }

        if ($request->hasFile('avatar')) {
            $this->deleteLocalUploadIfPresent($farm->avatar_url);
            $farm->avatar_url = $this->storePublicUpload($request->file('avatar'), 'farm_avatar');
        }

        if ($request->hasFile('cover_photo')) {
            $this->deleteLocalUploadIfPresent($farm->cover_photo_url);
            $farm->cover_photo_url = $this->storePublicUpload($request->file('cover_photo'), 'farm_cover');
        }

        $farm->save();

        return response()->json([
            'message'         => 'Farm media updated successfully.',
            'avatar_url'      => $this->normalizeUrl($farm->avatar_url, $request),
            'cover_photo_url' => $this->normalizeUrl($farm->cover_photo_url, $request),
        ]);
    }

    public function destroy(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $user = User::query()
            ->where('mobile_number', $validated['mobile_number'])
            ->firstOrFail();

        Farm::query()->where('user_id', $user->id)->delete();

        return response()->json([
            'message' => 'Farm deleted successfully.',
        ]);
    }

    private function farmPayload(Farm $farm, User $user, Request $request): array
    {
        return [
            'id'              => $farm->id,
            'name'            => $farm->name,
            'tagline'         => $farm->tagline,
            'farm_type'       => $farm->farm_type,
            'city'            => $farm->city,
            'province'        => $farm->province,
            'started_year'    => $farm->started_year,
            'story'           => $farm->story,
            'avatar_url'      => $this->normalizeUrl($farm->avatar_url, $request),
            'cover_photo_url' => $this->normalizeUrl($farm->cover_photo_url, $request),
            'birds_count'     => $farm->birds_count,
            'active_cycles'   => $farm->active_cycles,
            'eggs_incubating' => $farm->eggs_incubating,
            'owner_name'      => $user->name,
        ];
    }

    private function storePublicUpload(UploadedFile $file, string $prefix): string
    {
        $directory = public_path('uploads/farm');
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

        return url('uploads/farm/' . $filename);
    }

    private function deleteLocalUploadIfPresent(?string $absoluteUrl): void
    {
        if (! is_string($absoluteUrl) || $absoluteUrl === '') {
            return;
        }

        $path = parse_url($absoluteUrl, PHP_URL_PATH);
        if (! is_string($path) || ! str_starts_with($path, '/uploads/farm/')) {
            return;
        }

        $filePath = public_path(ltrim($path, '/'));
        if (File::exists($filePath)) {
            File::delete($filePath);
        }
    }

    private function normalizeUrl(?string $value, Request $request): ?string
    {
        if (! is_string($value) || trim($value) === '') {
            return null;
        }

        $trimmed = trim($value);
        $path = parse_url($trimmed, PHP_URL_PATH);

        if (is_string($path) && str_starts_with($path, '/uploads/')) {
            return rtrim($request->getSchemeAndHttpHost(), '/') . $path;
        }

        if (str_starts_with($trimmed, '/uploads/')) {
            return rtrim($request->getSchemeAndHttpHost(), '/') . $trimmed;
        }

        return $trimmed;
    }
}
