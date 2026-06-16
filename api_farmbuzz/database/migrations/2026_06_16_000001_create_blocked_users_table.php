<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('blocked_users', function (Blueprint $table): void {
            $table->id();
            $table->string('blocker_name');   // name of the person who blocked
            $table->string('blocked_name');   // name of the person who got blocked
            $table->timestamps();

            $table->unique(['blocker_name', 'blocked_name']);
            $table->index('blocker_name');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('blocked_users');
    }
};
