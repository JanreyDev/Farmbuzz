<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('social_connections', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('owner_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('target_user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('relation', ['friend', 'follower', 'following']);
            $table->timestamps();

            $table->unique(['owner_user_id', 'target_user_id', 'relation']);
            $table->index(['owner_user_id', 'relation']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('social_connections');
    }
};
