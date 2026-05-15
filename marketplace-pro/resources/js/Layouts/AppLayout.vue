<script setup>
import { Link, usePage } from '@inertiajs/vue3'
const page = usePage()
</script>

<template>
  <div class="min-h-screen bg-zinc-950 text-zinc-50">
    <div class="border-b border-zinc-800 bg-zinc-950/60 backdrop-blur sticky top-0 z-40">
      <div class="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <Link href="/app/dashboard" class="font-semibold">ConciergeMarket</Link>
          <span class="text-xs opacity-60">User Portal</span>
        </div>
        <div class="flex items-center gap-2 text-sm">
          <Link class="btn-ghost" href="/sell/wizard">Sell</Link>
          <Link class="btn-ghost" href="/buy/concierge">Buy</Link>
          <Link class="btn-ghost" href="/app/security">Security</Link>
          <Link class="btn-ghost" href="/app/notifications">Notifications</Link>
          <Link class="btn-primary" href="/logout" method="post" as="button">Logout</Link>
        </div>
      </div>
    </div>

    <div class="max-w-6xl mx-auto px-4 py-8 grid grid-cols-1 md:grid-cols-12 gap-6">
      <aside class="md:col-span-3 card p-4">
        <div class="text-sm opacity-70 mb-3">Menu</div>
        <div class="space-y-2 text-sm">
          <Link class="block opacity-90 hover:opacity-100" href="/app/dashboard">Dashboard</Link>
          <Link class="block opacity-90 hover:opacity-100" href="/sell/wizard">Sell onboarding</Link>
          <Link class="block opacity-90 hover:opacity-100" href="/buy/concierge">Buy onboarding</Link>
          <div class="pt-2 border-t border-zinc-800 mt-2"></div>
          <Link class="block opacity-90 hover:opacity-100" href="/app/security">Profile & Security</Link>
          <Link class="block opacity-90 hover:opacity-100" href="/app/notifications">Notifications</Link>
        </div>
      </aside>

      <main class="md:col-span-9">
        <slot />
      </main>
    </div>
  </div>
</template>
