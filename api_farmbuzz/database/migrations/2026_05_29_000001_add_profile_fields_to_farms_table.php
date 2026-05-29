<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('farms', function (Blueprint $table): void {
            $table->string('tagline')->nullable()->after('name');
            $table->string('province')->nullable()->after('city');
            $table->text('story')->nullable()->after('province');
            $table->string('avatar_url')->nullable()->after('story');
            $table->string('cover_photo_url')->nullable()->after('avatar_url');
        });
    }

    public function down(): void
    {
        Schema::table('farms', function (Blueprint $table): void {
            $table->dropColumn(['tagline', 'province', 'story', 'avatar_url', 'cover_photo_url']);
        });
    }
};
