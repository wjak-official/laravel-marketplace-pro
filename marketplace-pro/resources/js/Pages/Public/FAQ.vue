<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
const faqs = [
  { q: 'Do users talk directly?', a: 'No. The app is the single point of contact and issues one bill.' },
  { q: 'Can buyers source from the internet?', a: 'Yes if enabled; otherwise internal listings only.' },
  { q: 'What do activation fees cover?', a: 'Verification, concierge handling, and prioritization in matching.' },
]
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 py-16">
      <h1 class="text-4xl font-semibold" data-aos="fade-up">FAQ</h1>
      <div class="mt-10 grid gap-4">
        <div v-for="(f,i) in faqs" :key="i" class="card p-6" data-aos="fade-up" :data-aos-delay="i*80">
          <div class="font-semibold">{{ f.q }}</div>
          <div class="opacity-80 mt-2">{{ f.a }}</div>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
