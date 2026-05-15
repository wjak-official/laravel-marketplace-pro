<?php

namespace App\Policies;

use App\Models\User;
use App\Models\SellerListing;

class SellerListingPolicy
{
    public function view(User $user, SellerListing $listing): bool
    {
        return $user->hasRole('admin') || $listing->user_id === $user->id;
    }

    public function update(User $user, SellerListing $listing): bool
    {
        if ($user->hasRole('admin')) return true;
        return $listing->user_id === $user->id && in_array($listing->status, ['draft','pending_review'], true);
    }
}
