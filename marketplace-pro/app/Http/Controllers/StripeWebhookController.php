<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Stripe\Webhook;
use App\Models\SellerListing;
use App\Models\BuyerRequest;

class StripeWebhookController extends Controller
{
    public function handle(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $secret = config('services.stripe.webhook_secret');

        try {
            $event = Webhook::constructEvent($payload, $sigHeader, $secret);
        } catch (\Throwable $e) {
            return response('Invalid signature', 400);
        }

        if ($event->type === 'checkout.session.completed') {
            $session = $event->data->object;
            $type = $session->metadata->type ?? null;

            if ($type === 'seller_listing_activation') {
                $listingId = (int) ($session->metadata->listing_id ?? 0);
                SellerListing::whereKey($listingId)->update([
                    'status' => 'pending_review',
                    'activated_at' => now(),
                ]);
            }

            if ($type === 'buyer_request_activation') {
                $requestId = (int) ($session->metadata->request_id ?? 0);
                BuyerRequest::whereKey($requestId)->update([
                    'status' => 'active',
                    'activated_at' => now(),
                ]);
            }
        }

        return response('ok', 200);
    }
}
