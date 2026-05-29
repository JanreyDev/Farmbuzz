<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('featured_birds', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('farm_id')->constrained('farms')->cascadeOnDelete();
            $table->string('name', 120);
            $table->string('heritage_line', 120)->nullable();
            $table->string('age_label', 60)->nullable();
            $table->string('sex', 20)->nullable();
            $table->string('badge', 40)->nullable();
            $table->string('image_url', 500)->nullable();
            $table->timestamps();

            $table->index(['farm_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('featured_birds');
    }
};

