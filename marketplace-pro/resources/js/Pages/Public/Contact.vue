<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 py-16">
      <h1 class="text-4xl font-semibold" data-aos="fade-up">Contact</h1>
      <div class="grid md:grid-cols-2 gap-6 mt-10">
        <div class="card p-6" data-aos="fade-up">
          <div class="font-semibold">Support</div>
          <p class="opacity-80 mt-2">Email: support@example.com</p>
          <p class="opacity-80">Hours: Mon–Fri</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="100">
          <div class="font-semibold">Send a message</div>
          <div class="mt-4 space-y-3">
            <input class="input" placeholder="Your email" />
            <textarea class="input" rows="4" placeholder="Message"></textarea>
            <button class="btn-primary">Send</button>
          </div>
          <p class="text-xs opacity-60 mt-3">Hook this to a real form handler (SMTP/support inbox) before production.</p>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
