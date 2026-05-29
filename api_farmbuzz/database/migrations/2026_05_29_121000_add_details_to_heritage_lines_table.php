<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('heritage_lines', function (Blueprint $table): void {
            $table->string('origin_focus', 160)->nullable()->after('description');
            $table->string('traits', 300)->nullable()->after('origin_focus');
            $table->unsignedSmallInteger('generations_bred')->nullable()->after('traits');
        });
    }

    public function down(): void
    {
        Schema::table('heritage_lines', function (Blueprint $table): void {
            $table->dropColumn(['origin_focus', 'traits', 'generations_bred']);
        });
    }
};

