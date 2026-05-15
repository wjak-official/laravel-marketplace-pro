<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
import { ref, computed } from 'vue'
import { router } from '@inertiajs/vue3'
import axios from 'axios'

const props = defineProps({ fee: Number, currency: String })
const step = ref(1)
const listingId = ref(null)
const stepsTotal = 6

const form = ref({
  title: '', description: '', category: '', condition: 'used',
  price_min: null, price_max: null, pickup_city: '',
  attributes: {}, photos: [],
})

const progress = computed(() => Math.round((step.value / stepsTotal) * 100))
const canNext = computed(() => step.value === 1 ? (form.value.title && form.value.category) : true)

async function saveDraft() {
  const { data } = await axios.post(route('sell.draft'), { ...form.value, id: listingId.value })
  listingId.value = data.id
}
async function next() { if (!canNext.value) return; await saveDraft(); step.value = Math.min(stepsTotal, step.value + 1) }
function back() { step.value = Math.max(1, step.value - 1) }
async function checkout() { await saveDraft(); router.post(route('sell.checkout', listingId.value)) }
</script>

<template>
  <AppLayout>
    <div class="card p-6 overflow-hidden">
      <div class="flex items-center justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold">Seller Onboarding</h1>
          <p class="opacity-70 mt-1">A story-card wizard that captures everything we need to sell fast.</p>
        </div>
        <div class="text-sm opacity-70">Step {{ step }} / {{ stepsTotal }}</div>
      </div>

      <div class="mt-5 h-2 bg-zinc-800 rounded">
        <div class="h-2 bg-white rounded transition-all duration-300" :style="{ width: progress + '%' }"></div>
      </div>

      <div class="mt-6 relative">
        <transition name="fade" mode="out-in">
          <div :key="step" class="card p-6">
            <template v-if="step === 1">
              <div class="text-lg font-semibold">What are you selling?</div>
              <div class="mt-4 grid gap-3">
                <input class="input" v-model="form.title" placeholder="e.g., iPhone 14 Pro 256GB" />
                <div class="grid md:grid-cols-2 gap-3">
                  <input class="input" v-model="form.category" placeholder="Category (electronics, furniture...)" />
                  <select class="input" v-model="form.condition">
                    <option value="new">New</option>
                    <option value="like_new">Like new</option>
                    <option value="used">Used</option>
                    <option value="fair">Fair</option>
                  </select>
                </div>
              </div>
            </template>

            <template v-else-if="step === 2">
              <div class="text-lg font-semibold">Tell the story</div>
              <textarea class="input mt-4" rows="6" v-model="form.description"
                        placeholder="Condition notes, accessories, defects..." />
            </template>

            <template v-else-if="step === 3">
              <div class="text-lg font-semibold">Price expectation</div>
              <div class="grid md:grid-cols-2 gap-3 mt-4">
                <input class="input" type="number" v-model.number="form.price_min" placeholder="Min" />
                <input class="input" type="number" v-model.number="form.price_max" placeholder="Max" />
              </div>
              <p class="opacity-70 text-sm mt-2">Used for matching + offer guidance.</p>
            </template>

            <template v-else-if="step === 4">
              <div class="text-lg font-semibold">Pickup area</div>
              <input class="input mt-4" v-model="form.pickup_city" placeholder="City / area" />
              <p class="opacity-70 text-sm mt-2">Exact address confirmed after matching.</p>
            </template>

            <template v-else-if="step === 5">
              <div class="text-lg font-semibold">Quick attributes</div>
              <div class="grid md:grid-cols-2 gap-3 mt-4">
                <input class="input" placeholder="Brand" @input="form.attributes.brand=$event.target.value" />
                <input class="input" placeholder="Model" @input="form.attributes.model=$event.target.value" />
              </div>
            </template>

            <template v-else>
              <div class="text-lg font-semibold">Activate</div>
              <p class="opacity-80 mt-3">
                Activation fee: <span class="font-semibold">{{ (fee/100).toFixed(2) }} {{ currency }}</span>
              </p>
              <button class="btn-primary mt-5" @click="checkout">Pay & Activate</button>
              <p class="text-xs opacity-60 mt-3">After payment, status becomes pending review (admin can approve).</p>
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
