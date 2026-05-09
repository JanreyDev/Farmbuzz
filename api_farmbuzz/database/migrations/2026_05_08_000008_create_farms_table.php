<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('farms', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('name');
            $table->string('farm_type')->nullable();
            $table->string('city')->nullable();
            $table->unsignedSmallInteger('started_year')->nullable();
            $table->unsignedInteger('birds_count')->default(0);
            $table->unsignedInteger('active_cycles')->default(0);
            $table->unsignedInteger('eggs_incubating')->default(0);
            $table->timestamps();

            $table->unique('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('farms');
    }
};