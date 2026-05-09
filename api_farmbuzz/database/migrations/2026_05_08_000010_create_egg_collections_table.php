<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('egg_collections', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('farm_id')->constrained('farms')->cascadeOnDelete();
            $table->string('batch_name', 255);
            $table->unsignedInteger('egg_count');
            $table->date('collected_on');
            $table->string('note', 255)->nullable();
            $table->string('status', 30)->default('fresh');
            $table->timestamps();

            $table->index(['farm_id', 'collected_on']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('egg_collections');
    }
};
