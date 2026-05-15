<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
</script>

<template>
  <AppLayout>
    <div class="card p-6">
      <div class="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 class="text-2xl font-semibold">Dashboard</h1>
          <p class="opacity-70 mt-1">Your activity, matches, and orders in one place.</p>
        </div>
        <div class="flex gap-3">
          <a class="btn-ghost" href="/sell/wizard">Create listing</a>
          <a class="btn-primary" href="/buy/concierge">Create request</a>
        </div>
      </div>

      <div class="grid md:grid-cols-3 gap-4 mt-6">
        <div class="card p-4">
          <div class="text-sm opacity-70">Matches</div>
          <div class="text-3xl font-semibold mt-2">—</div>
          <div class="text-xs opacity-60 mt-1">Hook to matches API</div>
        </div>
        <div class="card p-4">
          <div class="text-sm opacity-70">Orders</div>
          <div class="text-3xl font-semibold mt-2">—</div>
          <div class="text-xs opacity-60 mt-1">Hook to orders API</div>
        </div>
        <div class="card p-4">
          <div class="text-sm opacity-70">Messages</div>
          <div class="text-3xl font-semibold mt-2">—</div>
          <div class="text-xs opacity-60 mt-1">Single point of contact</div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>
