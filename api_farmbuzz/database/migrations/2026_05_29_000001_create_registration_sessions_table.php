<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('registration_sessions', function (Blueprint $table): void {
            $table->id();
            $table->string('name');
            $table->string('referral_code', 50)->nullable();
            $table->boolean('is_at_least_18')->default(false);
            $table->boolean('accepted_terms')->default(false);
            $table->string('mobile_number')->nullable();
            $table->string('otp_code')->nullable();
            $table->timestamp('otp_sent_at')->nullable();
            $table->timestamp('mobile_verified_at')->nullable();
            $table->string('registration_status', 30)->default('started');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('registration_sessions');
    }
};

