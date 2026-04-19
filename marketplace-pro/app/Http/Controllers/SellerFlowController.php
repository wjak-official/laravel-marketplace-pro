<?php

namespace App\Http\Controllers;

use App\Models\SellerListing;
use Illuminate\Http\Request;

class SellerFlowController extends Controller
{
    public function wizard()
    {
        return inertia('Seller/Wizard', [
            'fee' => (int) config('services.fees.seller_listing', env('APP_FEE_SELLER_LISTING', 499)),
            'currency' => env('APP_CURRENCY','USD'),
        ]);
    }

    public function saveDraft(Request $request)
    {
        $data = $request->validate([
            'id' => 'nullable|integer',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|string|max:100',
            'condition' => 'required|in:new,like_new,used,fair',
            'price_min' => 'nullable|integer|min:0',
            'price_max' => 'nullable|integer|min:0',
            'pickup_city' => 'nullable|string|max:120',
            'attributes' => 'nullable|array',
            'photos' => 'nullable|array',
        ]);

        $listing = SellerListing::updateOrCreate(
            ['id' => $data['id'] ?? null, 'user_id' => $request->user()->id],
            array_merge(collect($data)->except('id')->toArray(), ['status' => 'draft'])
        );

        return response()->json(['id' => $listing->id]);
    }
}
