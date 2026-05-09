<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clubs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('category')->default('Community');
            $table->string('region')->nullable();
            $table->json('focus_tags')->nullable();
            $table->boolean('is_public')->default(true);
            $table->unsignedInteger('min_birds')->default(0);
            $table->boolean('verified_only')->default(false);
            $table->string('cover_image_url')->nullable();
            $table->unsignedInteger('member_count')->default(1);
            $table->unsignedInteger('post_count')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('clubs');
    }
};

