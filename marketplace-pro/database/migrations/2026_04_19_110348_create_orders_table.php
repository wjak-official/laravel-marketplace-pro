<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('orders', function (Blueprint $table) {
      $table->id();
      $table->foreignId('offer_id')->constrained()->cascadeOnDelete();
      $table->foreignId('buyer_id')->constrained('users')->cascadeOnDelete();
      $table->foreignId('seller_id')->nullable()->constrained('users')->nullOnDelete();
      $table->string('status')->default('pending_payment')->index();
      $table->unsignedInteger('total');
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->string('stripe_payment_intent_id')->nullable()->index();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('orders'); }
};
