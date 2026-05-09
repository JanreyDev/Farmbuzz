<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->string('email')->nullable()->change();
            $table->string('password')->nullable()->change();
            $table->string('mobile_number', 20)->nullable()->unique()->after('name');
            $table->string('referral_code', 50)->nullable()->after('mobile_number');
            $table->boolean('is_at_least_18')->default(false)->after('referral_code');
            $table->boolean('accepted_terms')->default(false)->after('is_at_least_18');
            $table->string('otp_code')->nullable()->after('accepted_terms');
            $table->timestamp('otp_sent_at')->nullable()->after('otp_code');
            $table->timestamp('mobile_verified_at')->nullable()->after('otp_sent_at');
            $table->string('pin')->nullable()->after('mobile_verified_at');
            $table->string('registration_status', 20)->default('started')->after('pin');
            $table->timestamp('registration_completed_at')->nullable()->after('registration_status');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->dropColumn([
                'mobile_number',
                'referral_code',
                'is_at_least_18',
                'accepted_terms',
                'otp_code',
                'otp_sent_at',
                'mobile_verified_at',
                'pin',
                'registration_status',
                'registration_completed_at',
            ]);

            $table->string('email')->nullable(false)->change();
            $table->string('password')->nullable(false)->change();
        });
    }
};
