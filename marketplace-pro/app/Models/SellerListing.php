<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SellerListing extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id','title','description','category','price_min','price_max','currency',
        'condition','status','photos','attributes','pickup_city','pickup_lat','pickup_lng',
        'available_from','available_to','activated_at'
    ];

    protected $casts = [
        'photos' => 'array',
        'attributes' => 'array',
        'available_from' => 'datetime',
        'available_to' => 'datetime',
        'activated_at' => 'datetime',
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function matches() { return $this->hasMany(MatchRecord::class); }
}
