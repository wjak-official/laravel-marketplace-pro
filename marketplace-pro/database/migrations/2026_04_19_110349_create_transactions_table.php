<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('transactions', function (Blueprint $table) {
      $table->id();
      $table->foreignId('order_id')->constrained()->cascadeOnDelete();
      $table->string('type')->index();
      $table->unsignedInteger('amount');
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->string('provider')->default('stripe')->index();
      $table->string('provider_ref')->nullable()->index();
      $table->string('status')->default('pending')->index();
      $table->json('meta')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('transactions'); }
};
