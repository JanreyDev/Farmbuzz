<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Post\StoreCommentRequest;
use App\Http\Requests\Post\StorePostRequest;
use App\Models\Comment;
use App\Models\Post;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;

class PostController extends Controller
{
    private function emojiForFeeling(?string $feeling): string
    {
        $normalized = mb_strtolower(trim((string) $feeling));
        if ($normalized === '') {
            return '';
        }

        return match ($normalized) {
            'happy', 'grateful', 'blessed', 'proud', 'excited', 'loved' => '😊',
            'sad', 'hurt', 'lonely', 'disappointed' => '😢',
            'angry', 'frustrated', 'annoyed' => '😠',
            'tired', 'sleepy' => '😴',
            'worried', 'anxious' => '😟',
            'sick' => '🤒',
            default => '🙂',
        };
    }

    private function topReactionsFor(Post $post): array
    {
        return $post->reactions()
            ->selectRaw('reaction, COUNT(*) as aggregate_count')
            ->groupBy('reaction')
            ->orderByDesc('aggregate_count')
            ->orderBy('reaction')
            ->limit(3)
            ->pluck('reaction')
            ->values()
            ->all();
    }

    public function index(Request $request): JsonResponse
    {
        $reactorName = trim((string) $request->query('reactor_name', ''));
        $authorName = trim((string) $request->query('author_name', ''));

        $query = Post::query()
            ->with('reactions')
            ->withCount(['reactions', 'comments'])
            ->latest('published_at')
            ->latest('id')
            ->limit(50);

        if ($authorName !== '') {
            $query->where('author_name', $authorName);
        }

        $posts = $query
            ->get()
            ->map(function (Post $post) use ($reactorName): array {
                $userReaction = null;

                if ($reactorName !== '') {
                    $userReaction = $post->reactions
                        ->firstWhere('reactor_name', $reactorName)?->reaction;
                }

                $normalizedImagePaths = collect($post->image_paths ?? [])
                    ->filter(fn ($path): bool => is_string($path))
                    ->map(fn (string $path): ?string => $this->normalizePublicUrl($path, request()))
                    ->filter(fn ($path): bool => is_string($path) && $path !== '')
                    ->values()
                    ->all();

                return [
                    'id' => $post->id,
                    'userName' => $post->author_name,
                    'userAvatar' => $post->author_avatar,
                    'timeAgo' => $post->published_at?->diffForHumans() ?? 'Just now',
                    'postText' => $post->content ?? '',
                    'metaEmoji' => $this->emojiForFeeling($post->meta_feeling),
                    'metaFeeling' => (string) ($post->meta_feeling ?? ''),
                    'metaLocation' => (string) ($post->meta_location ?? ''),
                    'postImageUrl' => null,
                    'imageUrls' => $normalizedImagePaths,
                    'likesCount' => (string) ($post->reactions_count ?? 0),
                    'commentsCount' => (string) ($post->comments_count ?? 0),
                    'userReaction' => $userReaction,
                    'topReactions' => $this->topReactionsFor($post),
                ];
            })
            ->values();

        return response()->json([
            'data' => $posts,
        ]);
    }

    public function store(StorePostRequest $request): JsonResponse
    {
        $storedPaths = [];
        foreach ($request->file('images', []) as $image) {
            if ($image instanceof UploadedFile) {
                $storedPaths[] = $this->storePublicPostImage($image, $request);
            }
        }
        foreach ((array) $request->input('image_payloads', []) as $payload) {
            if (is_string($payload) && trim($payload) !== '') {
                $stored = $this->storePublicPostImageFromBase64($payload, $request);
                if ($stored !== null) {
                    $storedPaths[] = $stored;
                }
            }
        }

        $post = Post::query()->create([
            'author_name' => $request->string('author_name')->toString(),
            'author_avatar' => $request->input('author_avatar'),
            'content' => $request->input('content'),
            'meta_feeling' => $request->input('meta_feeling'),
            'meta_location' => $request->input('meta_location'),
            'image_paths' => $storedPaths,
            'published_at' => now(),
        ]);

        return response()->json([
            'message' => 'Post created successfully.',
            'data' => [
                'id' => $post->id,
                'userName' => $post->author_name,
                'userAvatar' => $post->author_avatar,
                'timeAgo' => 'Just now',
                'postText' => $post->content ?? '',
                'metaEmoji' => $this->emojiForFeeling($post->meta_feeling),
                'metaFeeling' => (string) ($post->meta_feeling ?? ''),
                'metaLocation' => (string) ($post->meta_location ?? ''),
                'postImageUrl' => null,
                'imageUrls' => collect($post->image_paths ?? [])
                    ->filter(fn ($path): bool => is_string($path))
                    ->map(fn (string $path): ?string => $this->normalizePublicUrl($path, $request))
                    ->filter(fn ($path): bool => is_string($path) && $path !== '')
                    ->values()
                    ->all(),
                'likesCount' => '0',
                'commentsCount' => '0',
                'topReactions' => [],
            ],
        ], 201);
    }

    private function storePublicPostImage(UploadedFile $file, Request $request): string
    {
        $directory = public_path('uploads/posts');
        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $filename = sprintf(
            'post_%s_%s.%s',
            now()->format('YmdHisv'),
            bin2hex(random_bytes(4)),
            $file->getClientOriginalExtension(),
        );

        $file->move($directory, $filename);

        return rtrim($request->getSchemeAndHttpHost(), '/') . '/uploads/posts/' . $filename;
    }

    private function storePublicPostImageFromBase64(string $payload, Request $request): ?string
    {
        $normalized = trim($payload);
        if ($normalized === '') {
            return null;
        }

        $raw = $normalized;
        $declaredMime = null;
        if (preg_match('/^data:(?<mime>[-\w.]+\/[-\w.+]+);base64,(?<data>.+)$/', $normalized, $matches) === 1) {
            $declaredMime = $matches['mime'] ?? null;
            $raw = $matches['data'] ?? '';
        }

        $raw = preg_replace('/\s+/', '', $raw) ?? '';
        $binary = base64_decode($raw, true);
        if ($binary === false || $binary === '') {
            return null;
        }

        $detectedMime = (string) ((new \finfo(FILEINFO_MIME_TYPE))->buffer($binary) ?: '');
        $mime = $detectedMime !== '' ? $detectedMime : (string) $declaredMime;
        $allowed = [
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/webp' => 'webp',
            'image/gif' => 'gif',
            'image/bmp' => 'bmp',
        ];
        if (! array_key_exists($mime, $allowed)) {
            return null;
        }

        $directory = public_path('uploads/posts');
        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $filename = sprintf(
            'post_%s_%s.%s',
            now()->format('YmdHisv'),
            Str::lower(Str::random(8)),
            $allowed[$mime],
        );

        $target = $directory . DIRECTORY_SEPARATOR . $filename;
        File::put($target, $binary);

        return rtrim($request->getSchemeAndHttpHost(), '/') . '/uploads/posts/' . $filename;
    }

    private function normalizePublicUrl(?string $value, Request $request): ?string
    {
        if (! is_string($value)) {
            return null;
        }

        $trimmed = trim($value);
        if ($trimmed === '') {
            return null;
        }

        $path = parse_url($trimmed, PHP_URL_PATH);
        if (is_string($path) && str_starts_with($path, '/uploads/')) {
            return rtrim($request->getSchemeAndHttpHost(), '/') . $path;
        }

        if (str_starts_with($trimmed, '/uploads/')) {
            return rtrim($request->getSchemeAndHttpHost(), '/') . $trimmed;
        }

        return $trimmed;
    }

    public function like(Post $post): JsonResponse
    {
        $validated = request()->validate([
            'reactor_name' => ['required', 'string', 'max:255'],
            'reaction' => ['required', 'string', 'max:10'],
        ]);

        $post->reactions()->updateOrCreate(
            ['reactor_name' => $validated['reactor_name']],
            ['reaction' => $validated['reaction']],
        );

        $likesCount = $post->reactions()->count();
        $post->forceFill(['likes_count' => $likesCount])->save();
        $post->refresh();

        return response()->json([
            'message' => 'Post liked.',
            'likesCount' => (string) $likesCount,
            'userReaction' => $validated['reaction'],
            'topReactions' => $this->topReactionsFor($post),
        ]);
    }

    public function unlike(Post $post): JsonResponse
    {
        $validated = request()->validate([
            'reactor_name' => ['required', 'string', 'max:255'],
        ]);

        $post->reactions()
            ->where('reactor_name', $validated['reactor_name'])
            ->delete();

        $likesCount = $post->reactions()->count();
        $post->forceFill(['likes_count' => $likesCount])->save();
        $post->refresh();

        return response()->json([
            'message' => 'Post unliked.',
            'likesCount' => (string) $likesCount,
            'userReaction' => null,
            'topReactions' => $this->topReactionsFor($post),
        ]);
    }

    public function comments(Post $post): JsonResponse
    {
        $comments = $post->comments()
            ->latest('published_at')
            ->latest('id')
            ->get()
            ->map(function (Comment $comment): array {
                return [
                    'id' => $comment->id,
                    'name' => $comment->author_name,
                    'avatar' => $comment->author_avatar ?? 'https://i.pravatar.cc/150?u=farmbuzz-comment',
                    'text' => $comment->content,
                    'time' => $comment->published_at?->diffForHumans() ?? 'now',
                ];
            })
            ->values();

        return response()->json([
            'data' => $comments,
            'commentsCount' => (string) $comments->count(),
        ]);
    }

    public function addComment(StoreCommentRequest $request, Post $post): JsonResponse
    {
        $comment = $post->comments()->create([
            'author_name' => $request->string('author_name')->toString(),
            'author_avatar' => $request->input('author_avatar'),
            'content' => $request->string('content')->toString(),
            'published_at' => now(),
        ]);

        $commentsCount = $post->comments()->count();
        $post->forceFill(['comments_count' => $commentsCount])->save();

        return response()->json([
            'message' => 'Comment added.',
            'comment' => [
                'id' => $comment->id,
                'name' => $comment->author_name,
                'avatar' => $comment->author_avatar ?? 'https://i.pravatar.cc/150?u=farmbuzz-comment',
                'text' => $comment->content,
                'time' => 'now',
            ],
            'commentsCount' => (string) $commentsCount,
        ], 201);
    }
}
