<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Farm;
use App\Models\FarmGalleryPhoto;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;

class FarmGalleryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request, true);
        if (! $farm) {
            return response()->json([
                'message' => 'Farm not found.',
                'data' => [],
            ]);
        }

        $photos = FarmGalleryPhoto::query()
            ->where('farm_id', $farm->id)
            ->latest('id')
            ->get()
            ->map(fn (FarmGalleryPhoto $photo): array => $this->payload($photo, $request))
            ->values();

        return response()->json(['data' => $photos]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'photos' => ['required', 'array', 'min:1'],
            'photos.*' => ['required', 'image', 'max:8192'],
        ]);

        $farm = $this->resolveFarmForMobile($request);
        if (! $farm) {
            return response()->json(['message' => 'Farm not found.'], 404);
        }

        $created = [];
        foreach ($request->file('photos', []) as $photoFile) {
            if (! $photoFile instanceof UploadedFile) {
                continue;
            }

            $photo = FarmGalleryPhoto::query()->create([
                'farm_id' => $farm->id,
                'image_url' => $this->storePublicUpload($photoFile, 'farm_gallery'),
            ]);

            $created[] = $this->payload($photo, $request);
        }

        return response()->json([
            'message' => 'Photos uploaded successfully.',
            'data' => $created,
        ], 201);
    }

    public function destroy(Request $request, FarmGalleryPhoto $farmGalleryPhoto): JsonResponse
    {
        $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $farm = $this->resolveFarmForMobile($request);
        if (! $farm || $farmGalleryPhoto->farm_id !== $farm->id) {
            return response()->json(['message' => 'Photo not found.'], 404);
        }

        $this->deleteLocalUploadIfPresent($farmGalleryPhoto->image_url);
        $farmGalleryPhoto->delete();

        return response()->json(['message' => 'Photo deleted successfully.']);
    }

    private function payload(FarmGalleryPhoto $photo, Request $request): array
    {
        return [
            'id' => $photo->id,
            'image_url' => $this->normalizeUrl($photo->image_url, $request),
            'created_at' => optional($photo->created_at)?->toIso8601String() ?? '',
        ];
    }

    private function storePublicUpload(UploadedFile $file, string $prefix): string
    {
        $directory = public_path('uploads/farm_gallery');
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

        return url('uploads/farm_gallery/' . $filename);
    }

    private function deleteLocalUploadIfPresent(?string $absoluteUrl): void
    {
        if (! is_string($absoluteUrl) || $absoluteUrl === '') {
            return;
        }

        $path = parse_url($absoluteUrl, PHP_URL_PATH);
        if (! is_string($path) || ! str_starts_with($path, '/uploads/farm_gallery/')) {
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

    private function resolveFarmForMobile(Request $request, bool $allowNull = false): ?Farm
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

        if (! $farm && ! $allowNull) {
            return null;
        }

        return $farm;
    }
}

