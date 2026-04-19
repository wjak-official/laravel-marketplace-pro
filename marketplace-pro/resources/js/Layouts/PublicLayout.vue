<script setup>
import { onMounted } from 'vue'
import AOS from 'aos'
import 'aos/dist/aos.css'
import Lenis from '@studio-freight/lenis'
import { Link } from '@inertiajs/vue3'

onMounted(() => {
  AOS.init({ duration: 700, easing: 'ease-out-cubic', once: true })
  const lenis = new Lenis({ smoothWheel: true })
  function raf(time) { lenis.raf(time); requestAnimationFrame(raf) }
  requestAnimationFrame(raf)
})
</script>

<template>
  <div class="min-h-screen">
    <header class="sticky top-0 z-50 backdrop-blur bg-zinc-950/70 border-b border-zinc-800">
      <div class="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
        <Link href="/" class="font-semibold tracking-tight">ConciergeMarket</Link>
        <nav class="flex items-center gap-4 text-sm">
          <Link class="opacity-80 hover:opacity-100" href="/pricing">Pricing</Link>
          <Link class="opacity-80 hover:opacity-100" href="/faq">FAQ</Link>
          <Link class="opacity-80 hover:opacity-100" href="/about">About</Link>
          <Link class="opacity-80 hover:opacity-100" href="/contact">Contact</Link>
          <Link class="btn-ghost" href="/login">Log in</Link>
          <Link class="btn-primary" href="/register">Get started</Link>
        </nav>
      </div>
    </header>

    <main>
      <slot />
    </main>

    <footer class="border-t border-zinc-800 mt-20">
      <div class="max-w-6xl mx-auto px-4 py-10 text-sm opacity-80 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>© {{ new Date().getFullYear() }} ConciergeMarket. All rights reserved.</div>
        <div class="flex gap-4">
          <a href="/privacy" class="hover:opacity-100">Privacy</a>
          <a href="/terms" class="hover:opacity-100">Terms</a>
        </div>
      </div>
    </footer>
  </div>
</template>
