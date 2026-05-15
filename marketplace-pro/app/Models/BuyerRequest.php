<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class BuyerRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id','query','category','details','budget_min','budget_max','currency',
        'allow_external_sources','status','must_haves','nice_to_haves',
        'delivery_city','delivery_lat','delivery_lng','activated_at'
    ];

    protected $casts = [
        'allow_external_sources' => 'boolean',
        'must_haves' => 'array',
        'nice_to_haves' => 'array',
        'activated_at' => 'datetime',
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function matches() { return $this->hasMany(MatchRecord::class); }
}
