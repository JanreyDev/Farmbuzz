<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('flock_batches', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('farm_id')->constrained('farms')->cascadeOnDelete();
            $table->string('name');
            $table->string('category', 20)->default('batch');
            $table->string('stage', 20)->default('brooder');
            $table->unsignedInteger('count')->default(0);
            $table->date('started_on');
            $table->string('note', 255)->nullable();
            $table->timestamps();

            $table->index(['farm_id', 'stage']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('flock_batches');
    }
};
