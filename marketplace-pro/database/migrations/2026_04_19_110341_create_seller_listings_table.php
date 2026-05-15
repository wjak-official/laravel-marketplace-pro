<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('seller_listings', function (Blueprint $table) {
      $table->id();
      $table->foreignId('user_id')->constrained()->cascadeOnDelete();
      $table->string('title');
      $table->text('description')->nullable();
      $table->string('category')->index();
      $table->unsignedInteger('price_min')->nullable();
      $table->unsignedInteger('price_max')->nullable();
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->string('condition')->index();
      $table->string('status')->default('draft')->index(); // draft/pending_review/active/reserved/sold/archived
      $table->json('photos')->nullable();
      $table->json('attributes')->nullable();
      $table->string('pickup_city')->nullable();
      $table->decimal('pickup_lat', 10, 7)->nullable();
      $table->decimal('pickup_lng', 10, 7)->nullable();
      $table->timestamp('available_from')->nullable();
      $table->timestamp('available_to')->nullable();
      $table->timestamp('activated_at')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('seller_listings'); }
};
