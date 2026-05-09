<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('post_reactions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('post_id')->constrained('posts')->cascadeOnDelete();
            $table->string('reactor_name');
            $table->string('reaction', 10);
            $table->timestamps();

            $table->unique(['post_id', 'reactor_name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('post_reactions');
    }
};
