<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
import { ref, computed } from 'vue'
import { router } from '@inertiajs/vue3'
import axios from 'axios'

const props = defineProps({ fee: Number, currency: String })
const step = ref(1)
const requestId = ref(null)
const stepsTotal = 6

const form = ref({
  query: '', category: '', details: '',
  budget_min: null, budget_max: null,
  allow_external_sources: true,
  must_haves: { conditions: [] },
  nice_to_haves: {},
  delivery_city: '',
})

const progress = computed(() => Math.round((step.value / stepsTotal) * 100))
const canNext = computed(() => step.value === 1 ? (form.value.query && form.value.category) : true)

async function saveDraft() {
  const { data } = await axios.post(route('buy.draft'), { ...form.value, id: requestId.value })
  requestId.value = data.id
}
async function next() { if (!canNext.value) return; await saveDraft(); step.value = Math.min(stepsTotal, step.value + 1) }
function back() { step.value = Math.max(1, step.value - 1) }
async function checkout() { await saveDraft(); router.post(route('buy.checkout', requestId.value)) }
</script>

<template>
  <AppLayout>
    <div class="card p-6 overflow-hidden">
      <div class="flex items-center justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold">Buyer Concierge</h1>
          <p class="opacity-70 mt-1">Describe requirements — we match internal sellers and optionally external sources.</p>
        </div>
        <div class="text-sm opacity-70">Step {{ step }} / {{ stepsTotal }}</div>
      </div>

      <div class="mt-5 h-2 bg-zinc-800 rounded">
        <div class="h-2 bg-white rounded transition-all duration-300" :style="{ width: progress + '%' }"></div>
      </div>

      <div class="mt-6">
        <transition name="fade" mode="out-in">
          <div :key="step" class="card p-6">
            <template v-if="step === 1">
              <div class="text-lg font-semibold">What are you looking for?</div>
              <input class="input mt-4" v-model="form.query" placeholder="e.g., MacBook Pro M2 16GB" />
              <input class="input mt-3" v-model="form.category" placeholder="Category" />
            </template>

            <template v-else-if="step === 2">
              <div class="text-lg font-semibold">Must-haves & nice-to-haves</div>
              <textarea class="input mt-4" rows="5" v-model="form.details" placeholder="Specs, colors, acceptable alternatives..." />
              <p class="text-xs opacity-60 mt-2">This is where a drag-drop UI can be added next.</p>
            </template>

            <template v-else-if="step === 3">
              <div class="text-lg font-semibold">Budget</div>
              <div class="grid md:grid-cols-2 gap-3 mt-4">
                <input class="input" type="number" v-model.number="form.budget_min" placeholder="Min" />
                <input class="input" type="number" v-model.number="form.budget_max" placeholder="Max" />
              </div>
            </template>

            <template v-else-if="step === 4">
              <div class="text-lg font-semibold">Sourcing</div>
              <label class="mt-4 flex items-center gap-3">
                <input type="checkbox" v-model="form.allow_external_sources" />
                <span class="opacity-80">Allow external sourcing (internet)</span>
              </label>
            </template>

            <template v-else-if="step === 5">
              <div class="text-lg font-semibold">Delivery city</div>
              <input class="input mt-4" v-model="form.delivery_city" placeholder="City / area" />
            </template>

            <template v-else>
              <div class="text-lg font-semibold">Activate concierge</div>
              <p class="opacity-80 mt-3">
                Activation fee: <span class="font-semibold">{{ (fee/100).toFixed(2) }} {{ currency }}</span>
              </p>
              <button class="btn-primary mt-5" @click="checkout">Pay & Activate</button>
              <p class="text-xs opacity-60 mt-3">After payment, request becomes Active and matching starts.</p>
            </template>
          </div>
        </transition>
      </div>

      <div class="flex justify-between mt-6">
        <button class="btn-ghost" @click="back" :disabled="step===1">Back</button>
        <button class="btn-primary" @click="next" v-if="step<stepsTotal" :disabled="!canNext">Continue</button>
      </div>
    </div>

    <style>
    .fade-enter-active,.fade-leave-active{ transition: opacity .2s ease, transform .2s ease; }
    .fade-enter-from,.fade-leave-to{ opacity:0; transform: translateY(6px); }
    </style>
  </AppLayout>
</template>
