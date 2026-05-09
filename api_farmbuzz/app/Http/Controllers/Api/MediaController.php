<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class MediaController extends Controller
{
    public function show(Request $request)
    {
        $validated = $request->validate([
            'path' => ['required', 'string', 'max:1000'],
        ]);

        $path = ltrim(trim((string) $validated['path']), '/');
        if ($path === '' || ! str_starts_with($path, 'uploads/') || str_contains($path, '..')) {
            abort(404);
        }

        $absolutePath = public_path($path);
        if (! is_file($absolutePath)) {
            abort(404);
        }

        return response()->file($absolutePath, [
            'Cache-Control' => 'public, max-age=86400',
            'Connection' => 'close',
        ]);
    }
}

