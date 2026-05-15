<?php

namespace App\Policies;

use App\Models\User;
use App\Models\BuyerRequest;

class BuyerRequestPolicy
{
    public function view(User $user, BuyerRequest $buyerRequest): bool
    {
        return $user->hasRole('admin') || $buyerRequest->user_id === $user->id;
    }

    public function update(User $user, BuyerRequest $buyerRequest): bool
    {
        if ($user->hasRole('admin')) return true;
        return $buyerRequest->user_id === $user->id && in_array($buyerRequest->status, ['draft'], true);
    }
}
