<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('match_records', function (Blueprint $table) {
      $table->id();
      $table->foreignId('buyer_request_id')->constrained()->cascadeOnDelete();
      $table->foreignId('seller_listing_id')->nullable()->constrained()->nullOnDelete();
      $table->unsignedSmallInteger('score')->default(0)->index();
      $table->string('source')->default('internal')->index();
      $table->string('status')->default('suggested')->index();
      $table->json('external_payload')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('match_records'); }
};
