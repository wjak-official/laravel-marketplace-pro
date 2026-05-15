<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
</script>

<template>
  <AppLayout>
    <div class="card p-6">
      <h1 class="text-2xl font-semibold">Profile & Security</h1>
      <p class="opacity-70 mt-1">Manage your account settings securely.</p>

      <div class="grid md:grid-cols-2 gap-4 mt-6">
        <div class="card p-5">
          <div class="font-semibold">Password</div>
          <p class="opacity-70 text-sm mt-1">Use /user/profile to change password (Breeze default).</p>
          <a class="btn-primary mt-4 inline-flex" href="/user/profile">Open Profile</a>
        </div>
        <div class="card p-5">
          <div class="font-semibold">Two-factor auth</div>
          <p class="opacity-70 text-sm mt-1">Add 2FA later via Fortify/Jetstream or a Filament 2FA plugin.</p>
        </div>
      </div>
    </div>
  </AppLayout>
</template>
