<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Farm;
use App\Models\FeaturedBird;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;

class FeaturedBirdController extends Controller
{
    private const SEX_VALUES = ['male', 'female', 'unknown'];
    private const BADGE_VALUES = [
        'no_badge',
        'champion_show',
        'breeder',
        'top_hen',
        'rising_star',
        'foundation',
        'signature',
        'retired',
    ];

    public function index(Request $request): JsonResponse
    {
        $farm = $this->resolveFarmForMobile($request, true);
        if (! $farm) {
            return response()->json([
                'message' => 'Farm not found.',
                'data' => [],
            ]);
        }

        $birds = FeaturedBird::query()
            ->where('farm_id', $farm->id)
            ->latest('id')
            ->get()
            ->map(fn (FeaturedBird $bird): array => $this->payload($bird, $request))
            ->values();

        return response()->json(['data' => $birds]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'name' => ['required', 'string', 'max:120'],
            'heritage_line' => ['nullable', 'string', 'max:120'],
            'age_label' => ['nullable', 'string', 'max:60'],
            'sex' => ['nullable', 'string', 'in:' . implode(',', self::SEX_VALUES)],
            'badge' => ['nullable', 'string', 'in:' . implode(',', self::BADGE_VALUES)],
            'image' => ['nullable', 'image', 'max:5120'],
        ]);

        $farm = $this->resolveFarmForMobile($request);
        if (! $farm) {
            return response()->json(['message' => 'Farm not found.'], 404);
        }

        $bird = FeaturedBird::query()->create([
            'farm_id' => $farm->id,
            'name' => trim((string) $validated['name']),
            'heritage_line' => $this->cleanNullableString($validated['heritage_line'] ?? null),
            'age_label' => $this->cleanNullableString($validated['age_label'] ?? null),
            'sex' => $this->cleanNullableString($validated['sex'] ?? null),
            'badge' => $this->cleanNullableString($validated['badge'] ?? null),
        ]);

        if ($request->hasFile('image')) {
            $bird->image_url = $this->storePublicUpload($request->file('image'), 'featured_bird');
            $bird->save();
        }

        return response()->json([
            'message' => 'Featured bird added successfully.',
            'data' => $this->payload($bird, $request),
        ], 201);
    }

    public function update(Request $request, FeaturedBird $featuredBird): JsonResponse
    {
        $validated = $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
            'name' => ['required', 'string', 'max:120'],
            'heritage_line' => ['nullable', 'string', 'max:120'],
            'age_label' => ['nullable', 'string', 'max:60'],
            'sex' => ['nullable', 'string', 'in:' . implode(',', self::SEX_VALUES)],
            'badge' => ['nullable', 'string', 'in:' . implode(',', self::BADGE_VALUES)],
            'remove_image' => ['nullable', 'boolean'],
            'image' => ['nullable', 'image', 'max:5120'],
        ]);

        $farm = $this->resolveFarmForMobile($request);
        if (! $farm || $featuredBird->farm_id !== $farm->id) {
            return response()->json(['message' => 'Featured bird not found.'], 404);
        }

        $featuredBird->name = trim((string) $validated['name']);
        $featuredBird->heritage_line = $this->cleanNullableString($validated['heritage_line'] ?? null);
        $featuredBird->age_label = $this->cleanNullableString($validated['age_label'] ?? null);
        $featuredBird->sex = $this->cleanNullableString($validated['sex'] ?? null);
        $featuredBird->badge = $this->cleanNullableString($validated['badge'] ?? null);

        if (($validated['remove_image'] ?? false) === true) {
            $this->deleteLocalUploadIfPresent($featuredBird->image_url);
            $featuredBird->image_url = null;
        }

        if ($request->hasFile('image')) {
            $this->deleteLocalUploadIfPresent($featuredBird->image_url);
            $featuredBird->image_url = $this->storePublicUpload($request->file('image'), 'featured_bird');
        }

        $featuredBird->save();

        return response()->json([
            'message' => 'Featured bird updated successfully.',
            'data' => $this->payload($featuredBird, $request),
        ]);
    }

    public function destroy(Request $request, FeaturedBird $featuredBird): JsonResponse
    {
        $request->validate([
            'mobile_number' => ['required', 'string', 'exists:users,mobile_number'],
        ]);

        $farm = $this->resolveFarmForMobile($request);
        if (! $farm || $featuredBird->farm_id !== $farm->id) {
            return response()->json(['message' => 'Featured bird not found.'], 404);
        }

        $this->deleteLocalUploadIfPresent($featuredBird->image_url);
        $featuredBird->delete();

        return response()->json([
            'message' => 'Featured bird deleted successfully.',
        ]);
    }

    private function cleanNullableString(mixed $value): ?string
    {
        if (! is_string($value)) {
            return null;
        }

        $trimmed = trim($value);
        return $trimmed === '' ? null : $trimmed;
    }

    private function payload(FeaturedBird $bird, Request $request): array
    {
        return [
            'id' => $bird->id,
            'name' => $bird->name,
            'heritage_line' => $bird->heritage_line ?? '',
            'age_label' => $bird->age_label ?? '',
            'sex' => $bird->sex ?? '',
            'badge' => $bird->badge ?? '',
            'image_url' => $this->normalizeUrl($bird->image_url, $request),
            'created_at' => optional($bird->created_at)?->toIso8601String() ?? '',
        ];
    }

    private function storePublicUpload(UploadedFile $file, string $prefix): string
    {
        $directory = public_path('uploads/featured_birds');
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

        return url('uploads/featured_birds/' . $filename);
    }

    private function deleteLocalUploadIfPresent(?string $absoluteUrl): void
    {
        if (! is_string($absoluteUrl) || $absoluteUrl === '') {
            return;
        }

        $path = parse_url($absoluteUrl, PHP_URL_PATH);
        if (! is_string($path) || ! str_starts_with($path, '/uploads/featured_birds/')) {
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

