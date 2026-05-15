<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id','type','amount','currency','provider','provider_ref','status','meta'
    ];

    protected $casts = [
        'meta' => 'array'
    ];

    public function order() { return $this->belongsTo(Order::class); }
}
