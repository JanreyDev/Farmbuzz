<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function search(Request ): JsonResponse
    {
         = ->validate([
            'q' => ['nullable', 'string', 'max:255'],
        ]);

         = ['q'] ?? '';

        if (empty()) {
            return response()->json(['data' => []]);
        }

         = User::query()
            ->where('name', 'LIKE', '%' .  . '%')
            ->orderBy('name', 'asc')
            ->limit(20)
            ->get(['id', 'name', 'avatar_url', 'mobile_number']);

        return response()->json(['data' => ]);
    }
}