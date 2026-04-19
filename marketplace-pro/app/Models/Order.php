<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'offer_id','buyer_id','seller_id','status','total','currency','stripe_payment_intent_id'
    ];

    public function offer() { return $this->belongsTo(Offer::class); }
    public function buyer() { return $this->belongsTo(User::class, 'buyer_id'); }
    public function seller() { return $this->belongsTo(User::class, 'seller_id'); }
    public function transactions() { return $this->hasMany(Transaction::class); }
    public function shipment() { return $this->hasOne(Shipment::class); }
}
