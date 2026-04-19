<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Shipment extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id','courier','tracking_number','status','pickup','dropoff','events'
    ];

    protected $casts = [
        'pickup' => 'array',
        'dropoff' => 'array',
        'events' => 'array',
    ];

    public function order() { return $this->belongsTo(Order::class); }
}
