<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('years_breeding')->nullable();
            $table->text('bio')->nullable();
            $table->string('address')->nullable();
            $table->string('bloodlines')->nullable();
            $table->string('social_fb')->nullable();
            $table->string('social_ig')->nullable();
            $table->string('social_tiktok')->nullable();
            $table->string('social_yt')->nullable();
            $table->string('social_web')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'years_breeding',
                'bio',
                'address',
                'bloodlines',
                'social_fb',
                'social_ig',
                'social_tiktok',
                'social_yt',
                'social_web',
            ]);
        });
    }
};
