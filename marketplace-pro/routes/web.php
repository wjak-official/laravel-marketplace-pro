<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PublicController;
use App\Http\Controllers\AppController;
use App\Http\Controllers\SellerFlowController;
use App\Http\Controllers\BuyerFlowController;
use App\Http\Controllers\PaymentsController;
use App\Http\Controllers\StripeWebhookController;

Route::get('/', [PublicController::class, 'home'])->name('home');
Route::get('/pricing', [PublicController::class, 'pricing'])->name('pricing');
Route::get('/faq', [PublicController::class, 'faq'])->name('faq');
Route::get('/about', [PublicController::class, 'about'])->name('about');
Route::get('/contact', [PublicController::class, 'contact'])->name('contact');

Route::middleware(['auth','verified'])->group(function () {
    Route::get('/app/dashboard', [AppController::class, 'dashboard'])->name('app.dashboard');
    Route::get('/app/security', [AppController::class, 'security'])->name('app.security');
    Route::get('/app/notifications', [AppController::class, 'notifications'])->name('app.notifications');

    Route::get('/sell/wizard', [SellerFlowController::class, 'wizard'])->name('sell.wizard');
    Route::post('/sell/draft', [SellerFlowController::class, 'saveDraft'])->name('sell.draft');
    Route::post('/sell/checkout/{listing}', [PaymentsController::class, 'sellerCheckout'])->name('sell.checkout');

    Route::get('/buy/concierge', [BuyerFlowController::class, 'concierge'])->name('buy.concierge');
    Route::post('/buy/draft', [BuyerFlowController::class, 'saveDraft'])->name('buy.draft');
    Route::post('/buy/checkout/{buyerRequest}', [PaymentsController::class, 'buyerCheckout'])->name('buy.checkout');
});

Route::post('/stripe/webhook', [StripeWebhookController::class, 'handle'])
    ->withoutMiddleware([\App\Http\Middleware\VerifyCsrfToken::class])
    ->name('stripe.webhook');

require __DIR__.'/auth.php';
