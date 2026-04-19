<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('offers', function (Blueprint $table) {
      $table->id();
      $table->foreignId('match_record_id')->constrained()->cascadeOnDelete();
      $table->unsignedInteger('item_price');
      $table->unsignedInteger('platform_fee');
      $table->unsignedInteger('delivery_fee');
      $table->unsignedInteger('tax')->default(0);
      $table->unsignedInteger('total');
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->string('status')->default('draft')->index(); // draft/sent/accepted/rejected/expired
      $table->json('breakdown')->nullable();
      $table->timestamp('expires_at')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('offers'); }
};
