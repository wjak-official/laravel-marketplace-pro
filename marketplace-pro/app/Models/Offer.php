<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Offer extends Model
{
    use HasFactory;

    protected $fillable = [
        'match_record_id','item_price','platform_fee','delivery_fee','tax','total','currency',
        'status','breakdown','expires_at'
    ];

    protected $casts = [
        'breakdown' => 'array',
        'expires_at' => 'datetime',
    ];

    public function matchRecord() { return $this->belongsTo(MatchRecord::class); }
    public function order() { return $this->hasOne(Order::class); }
}
