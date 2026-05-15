<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('shipments', function (Blueprint $table) {
      $table->id();
      $table->foreignId('order_id')->constrained()->cascadeOnDelete();
      $table->string('courier')->nullable();
      $table->string('tracking_number')->nullable()->index();
      $table->string('status')->default('pending')->index();
      $table->json('pickup')->nullable();
      $table->json('dropoff')->nullable();
      $table->json('events')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('shipments'); }
};
