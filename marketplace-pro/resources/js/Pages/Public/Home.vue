<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
import { Link } from '@inertiajs/vue3'
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 pt-16 pb-10">
      <div class="grid md:grid-cols-12 gap-8 items-center">
        <div class="md:col-span-7" data-aos="fade-up">
          <p class="text-xs uppercase tracking-widest opacity-70">Sell & buy with one point of contact</p>
          <h1 class="text-4xl md:text-6xl font-semibold leading-tight mt-3">
            Concierge marketplace that handles sourcing, selling, and delivery.
          </h1>
          <p class="opacity-80 mt-4 text-lg">
            Sellers list in minutes. Buyers describe what they want. We match, negotiate, arrange logistics, and bill from the platform.
          </p>
          <div class="mt-6 flex flex-wrap gap-3">
            <Link class="btn-primary" href="/register">Start now</Link>
            <a class="btn-ghost" href="#how">How it works</a>
            <a class="btn-ghost" href="#pricing">Pricing</a>
          </div>

          <div class="mt-8 grid grid-cols-3 gap-3">
            <div class="card p-4">
              <div class="text-2xl font-semibold">1</div>
              <div class="text-sm opacity-70 mt-1">Single bill</div>
            </div>
            <div class="card p-4">
              <div class="text-2xl font-semibold">2</div>
              <div class="text-sm opacity-70 mt-1">Concierge matching</div>
            </div>
            <div class="card p-4">
              <div class="text-2xl font-semibold">3</div>
              <div class="text-sm opacity-70 mt-1">Managed logistics</div>
            </div>
          </div>
        </div>

        <div class="md:col-span-5" data-aos="fade-left">
          <div class="card p-6">
            <div class="text-sm opacity-70">Try the experience</div>
            <div class="mt-4 space-y-3">
              <div class="card p-4">
                <div class="font-medium">Seller Onboarding</div>
                <p class="text-sm opacity-70 mt-1">Create a story-card listing wizard.</p>
              </div>
              <div class="card p-4">
                <div class="font-medium">Buyer Concierge</div>
                <p class="text-sm opacity-70 mt-1">Describe requirements; get matched options.</p>
              </div>
            </div>
            <div class="mt-5 flex gap-3">
              <Link class="btn-primary" href="/login">Launch portal</Link>
              <Link class="btn-ghost" href="/pricing">View pricing</Link>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="how" class="max-w-6xl mx-auto px-4 py-14">
      <div class="grid md:grid-cols-3 gap-6">
        <div class="card p-6" data-aos="fade-up">
          <div class="text-lg font-semibold">Sell</div>
          <p class="opacity-80 mt-2">Onboard with a guided wizard, pay a small activation fee, and we bring buyers.</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="100">
          <div class="text-lg font-semibold">Buy</div>
          <p class="opacity-80 mt-2">Explain what you want, must-haves vs nice-to-haves, and activate concierge sourcing.</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="200">
          <div class="text-lg font-semibold">We handle logistics</div>
          <p class="opacity-80 mt-2">Pickup, delivery, sourcing, verification, and a single invoice from the platform.</p>
        </div>
      </div>
    </section>

    <section id="pricing" class="max-w-6xl mx-auto px-4 py-14">
      <div class="flex items-end justify-between gap-6 flex-wrap">
        <div data-aos="fade-up">
          <h2 class="text-3xl font-semibold">Pricing</h2>
          <p class="opacity-80 mt-2">Simple activation fees + transparent platform fees per order.</p>
        </div>
        <Link class="btn-primary" href="/pricing" data-aos="fade-left">Full pricing</Link>
      </div>

      <div class="grid md:grid-cols-3 gap-6 mt-8">
        <div class="card p-6" data-aos="zoom-in">
          <div class="text-sm opacity-70">Seller activation</div>
          <div class="text-4xl font-semibold mt-2">$4.99</div>
          <ul class="text-sm opacity-80 mt-4 space-y-2">
            <li>• Listing verification</li>
            <li>• Matching visibility</li>
            <li>• Concierge support</li>
          </ul>
        </div>
        <div class="card p-6 border-white/20" data-aos="zoom-in" data-aos-delay="100">
          <div class="text-sm opacity-70">Buyer activation</div>
          <div class="text-4xl font-semibold mt-2">$4.99</div>
          <ul class="text-sm opacity-80 mt-4 space-y-2">
            <li>• Matching & sourcing</li>
            <li>• Offer breakdown</li>
            <li>• Priority handling</li>
          </ul>
        </div>
        <div class="card p-6" data-aos="zoom-in" data-aos-delay="200">
          <div class="text-sm opacity-70">Order platform fee</div>
          <div class="text-4xl font-semibold mt-2">X%</div>
          <ul class="text-sm opacity-80 mt-4 space-y-2">
            <li>• Handling + logistics</li>
            <li>• Single invoice</li>
            <li>• Dispute support</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="max-w-6xl mx-auto px-4 py-14">
      <div class="card p-8 flex flex-col md:flex-row md:items-center md:justify-between gap-6" data-aos="fade-up">
        <div>
          <h3 class="text-2xl font-semibold">Ready to try it?</h3>
          <p class="opacity-80 mt-2">Create an account and experience the onboarding flows.</p>
        </div>
        <div class="flex gap-3">
          <Link class="btn-primary" href="/register">Get started</Link>
          <Link class="btn-ghost" href="/faq">Read FAQ</Link>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
