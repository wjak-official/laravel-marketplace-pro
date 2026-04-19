<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 py-16">
      <h1 class="text-4xl font-semibold" data-aos="fade-up">Pricing</h1>
      <p class="opacity-80 mt-3 max-w-2xl" data-aos="fade-up" data-aos-delay="100">
        Transparent activation fees and order fees. Admin can adjust everything in Settings.
      </p>

      <div class="grid md:grid-cols-3 gap-6 mt-10">
        <div class="card p-6" data-aos="fade-up">
          <div class="text-lg font-semibold">Seller Activation</div>
          <div class="text-4xl font-semibold mt-2">$4.99</div>
          <p class="opacity-80 mt-3">Publish + concierge verification pipeline.</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="100">
          <div class="text-lg font-semibold">Buyer Activation</div>
          <div class="text-4xl font-semibold mt-2">$4.99</div>
          <p class="opacity-80 mt-3">Matching + optional external sourcing.</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="200">
          <div class="text-lg font-semibold">Order Fee</div>
          <div class="text-4xl font-semibold mt-2">Configurable</div>
          <p class="opacity-80 mt-3">Platform + delivery + taxes in one invoice.</p>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
