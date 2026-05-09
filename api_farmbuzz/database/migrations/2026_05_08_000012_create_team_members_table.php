<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('team_members', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('farm_id')->constrained('farms')->cascadeOnDelete();
            $table->string('name');
            $table->string('mobile_number', 20);
            $table->string('role', 40)->default('caretaker');
            $table->string('status', 20)->default('active');
            $table->timestamps();

            $table->unique(['farm_id', 'mobile_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('team_members');
    }
};
