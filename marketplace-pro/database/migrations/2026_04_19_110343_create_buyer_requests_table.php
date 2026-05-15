<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('buyer_requests', function (Blueprint $table) {
      $table->id();
      $table->foreignId('user_id')->constrained()->cascadeOnDelete();
      $table->string('query');
      $table->string('category')->index();
      $table->text('details')->nullable();
      $table->unsignedInteger('budget_min')->nullable();
      $table->unsignedInteger('budget_max')->nullable();
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->boolean('allow_external_sources')->default(true);
      $table->string('status')->default('draft')->index();
      $table->json('must_haves')->nullable();
      $table->json('nice_to_haves')->nullable();
      $table->string('delivery_city')->nullable();
      $table->decimal('delivery_lat', 10, 7)->nullable();
      $table->decimal('delivery_lng', 10, 7)->nullable();
      $table->timestamp('activated_at')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('buyer_requests'); }
};
