<?php

namespace App\Http\Controllers;

use App\Models\SellerListing;
use App\Models\BuyerRequest;
use Illuminate\Http\Request;
use Stripe\StripeClient;

class PaymentsController extends Controller
{
    private function stripe(): StripeClient
    {
        return new StripeClient(config('services.stripe.secret'));
    }

    public function sellerCheckout(Request $request, SellerListing $listing)
    {
        $this->authorize('update', $listing);

        $fee = (int) config('services.fees.seller_listing');
        $currency = strtolower($listing->currency ?? env('APP_CURRENCY','USD'));

        $session = $this->stripe()->checkout->sessions->create([
            'mode' => 'payment',
            'customer_email' => $request->user()->email,
            'line_items' => [[
                'quantity' => 1,
                'price_data' => [
                    'currency' => $currency,
                    'unit_amount' => $fee,
                    'product_data' => ['name' => 'Seller Listing Activation'],
                ],
            ]],
            'metadata' => [
                'type' => 'seller_listing_activation',
                'listing_id' => (string) $listing->id,
                'user_id' => (string) $request->user()->id,
            ],
            'success_url' => url("/app/dashboard?paid=1"),
            'cancel_url' => url("/sell/wizard?cancel=1"),
        ]);

        return redirect($session->url);
    }

    public function buyerCheckout(Request $request, BuyerRequest $buyerRequest)
    {
        $this->authorize('update', $buyerRequest);

        $fee = (int) config('services.fees.buyer_request');
        $currency = strtolower($buyerRequest->currency ?? env('APP_CURRENCY','USD'));

        $session = $this->stripe()->checkout->sessions->create([
            'mode' => 'payment',
            'customer_email' => $request->user()->email,
            'line_items' => [[
                'quantity' => 1,
                'price_data' => [
                    'currency' => $currency,
                    'unit_amount' => $fee,
                    'product_data' => ['name' => 'Buyer Concierge Activation'],
                ],
            ]],
            'metadata' => [
                'type' => 'buyer_request_activation',
                'request_id' => (string) $buyerRequest->id,
                'user_id' => (string) $request->user()->id,
            ],
            'success_url' => url("/app/dashboard?paid=1"),
            'cancel_url' => url("/buy/concierge?cancel=1"),
        ]);

        return redirect($session->url);
    }
}
