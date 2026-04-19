<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class MatchRecord extends Model
{
    use HasFactory;

    protected $fillable = [
        'buyer_request_id','seller_listing_id','score','source','status','external_payload'
    ];

    protected $casts = [
        'external_payload' => 'array',
    ];

    public function buyerRequest() { return $this->belongsTo(BuyerRequest::class); }
    public function sellerListing() { return $this->belongsTo(SellerListing::class); }
    public function offers() { return $this->hasMany(Offer::class); }
}
