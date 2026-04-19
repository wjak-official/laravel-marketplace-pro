<?php

namespace App\Http\Controllers;

use App\Models\BuyerRequest;
use Illuminate\Http\Request;

class BuyerFlowController extends Controller
{
    public function concierge()
    {
        return inertia('Buyer/Concierge', [
            'fee' => (int) config('services.fees.buyer_request', env('APP_FEE_BUYER_REQUEST', 499)),
            'currency' => env('APP_CURRENCY','USD'),
        ]);
    }

    public function saveDraft(Request $request)
    {
        $data = $request->validate([
            'id' => 'nullable|integer',
            'query' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'details' => 'nullable|string',
            'budget_min' => 'nullable|integer|min:0',
            'budget_max' => 'nullable|integer|min:0',
            'allow_external_sources' => 'boolean',
            'must_haves' => 'nullable|array',
            'nice_to_haves' => 'nullable|array',
            'delivery_city' => 'nullable|string|max:120',
        ]);

        $req = BuyerRequest::updateOrCreate(
            ['id' => $data['id'] ?? null, 'user_id' => $request->user()->id],
            array_merge(collect($data)->except('id')->toArray(), ['status' => 'draft'])
        );

        return response()->json(['id' => $req->id]);
    }
}
