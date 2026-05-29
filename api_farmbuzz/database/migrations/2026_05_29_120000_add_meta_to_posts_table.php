<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('posts', function (Blueprint $table): void {
            $table->string('meta_feeling', 120)->nullable()->after('content');
            $table->string('meta_location', 255)->nullable()->after('meta_feeling');
        });
    }

    public function down(): void
    {
        Schema::table('posts', function (Blueprint $table): void {
            $table->dropColumn(['meta_feeling', 'meta_location']);
        });
    }
};

