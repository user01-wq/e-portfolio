<script setup>
import { ref, inject, onMounted, computed } from 'vue'
import { supabase } from '../lib/supabase'

const isLight = inject('isLight', ref(false))

// ── Form fields ───────────────────────────────────────────────────────────────
const name     = ref('')
const email    = ref('')
const message  = ref('')
const honeypot = ref('')   // hidden — bots fill this, humans don't

// ── Math CAPTCHA ──────────────────────────────────────────────────────────────
const captchaA   = ref(0)
const captchaB   = ref(0)
const captchaAns = ref('')
const captchaCorrect = computed(() => parseInt(captchaAns.value) === captchaA.value + captchaB.value)

function newCaptcha() {
  captchaA.value   = Math.floor(Math.random() * 9) + 1
  captchaB.value   = Math.floor(Math.random() * 9) + 1
  captchaAns.value = ''
}
onMounted(newCaptcha)

// ── Submit state ──────────────────────────────────────────────────────────────
const submitting = ref(false)
const toast      = ref(null)   // { type: 'success'|'error', text: string }
const formSent   = ref(false)

async function submit() {
  // Honeypot check
  if (honeypot.value) return

  // CAPTCHA check
  if (!captchaCorrect.value) {
    toast.value = { type: 'error', text: 'คำตอบ CAPTCHA ไม่ถูกต้อง กรุณาลองใหม่' }
    newCaptcha()
    setTimeout(() => toast.value = null, 4000)
    return
  }

  submitting.value = true
  try {
    const { error } = await supabase.from('contact_messages').insert({
      name:    name.value.trim(),
      email:   email.value.trim() || null,
      message: message.value.trim(),
    })
    if (error) throw error

    formSent.value = true
    toast.value    = { type: 'success', text: 'ส่งข้อความเรียบร้อยแล้ว ขอบคุณครับ/ค่ะ 🙏' }
    setTimeout(() => toast.value = null, 5000)
  } catch (err) {
    toast.value = { type: 'error', text: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง' }
    setTimeout(() => toast.value = null, 4000)
  } finally {
    submitting.value = false
  }
}

function reset() {
  name.value = ''
  email.value = ''
  message.value = ''
  honeypot.value = ''
  formSent.value = false
  newCaptcha()
}
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12 relative z-10">

    <!-- Heading -->
    <div class="text-center mb-10">
      <div :class="[
        'inline-flex items-center justify-center w-16 h-16 rounded-2xl mb-5 shadow-lg',
        isLight ? 'bg-white border border-slate-200' : 'bg-white/10 backdrop-blur-md border border-white/20',
      ]">
        <svg class="w-8 h-8" :class="isLight ? 'text-slate-700' : 'text-white'" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"/>
        </svg>
      </div>
      <h1 :class="['text-3xl sm:text-4xl font-extrabold drop-shadow-md mb-3', isLight ? 'text-slate-800' : 'text-white']">
        ติดต่อ / แนะนำติชม
      </h1>
      <p :class="['text-sm leading-relaxed', isLight ? 'text-slate-500' : 'text-slate-300']">
        มีข้อสงสัย ข้อเสนอแนะ หรืออยากติดต่อ<br>
        ส่งข้อความมาได้เลย ข้อความจะถึงผู้ดูแลโดยตรง
      </p>
    </div>

    <!-- Toast -->
    <transition name="toast">
      <div
        v-if="toast"
        :class="[
          'fixed top-24 left-1/2 -translate-x-1/2 z-50 flex items-center gap-3 px-5 py-3.5 rounded-2xl shadow-2xl border text-sm font-medium transition-all',
          toast.type === 'success'
            ? 'bg-emerald-50 border-emerald-200 text-emerald-800'
            : 'bg-red-50 border-red-200 text-red-800',
        ]"
      >
        <svg v-if="toast.type === 'success'" class="w-5 h-5 text-emerald-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        <svg v-else class="w-5 h-5 text-red-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        {{ toast.text }}
      </div>
    </transition>

    <!-- Success state -->
    <div
      v-if="formSent"
      :class="[
        'rounded-2xl border p-10 text-center shadow-xl',
        isLight ? 'bg-white border-slate-200' : 'bg-white/10 backdrop-blur-xl border-white/15',
      ]"
    >
      <div class="w-16 h-16 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-4">
        <svg class="w-9 h-9 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
      </div>
      <h2 :class="['text-xl font-bold mb-2', isLight ? 'text-slate-800' : 'text-white']">ส่งข้อความสำเร็จแล้ว!</h2>
      <p :class="['text-sm mb-6', isLight ? 'text-slate-500' : 'text-slate-300']">ขอบคุณที่ติดต่อมานะครับ/ค่ะ ผู้ดูแลจะได้รับข้อความของคุณเร็วๆ นี้</p>
      <button
        @click="reset"
        :class="[
          'px-6 py-2.5 rounded-xl text-sm font-semibold transition-all',
          isLight ? 'bg-slate-100 text-slate-700 hover:bg-slate-200' : 'bg-white/10 text-white hover:bg-white/20 border border-white/10',
        ]"
      >
        ส่งข้อความอีกครั้ง
      </button>
    </div>

    <!-- Form -->
    <form
      v-else
      @submit.prevent="submit"
      :class="[
        'rounded-2xl border shadow-xl p-6 sm:p-8 space-y-5',
        isLight ? 'bg-white border-slate-200' : 'bg-white/10 backdrop-blur-xl border-white/15',
      ]"
    >
      <!-- Honeypot (hidden from humans, bots fill it) -->
      <div class="absolute -left-[9999px] -top-[9999px] opacity-0 pointer-events-none" aria-hidden="true">
        <label for="hp_website">Website</label>
        <input id="hp_website" v-model="honeypot" type="text" name="website" tabindex="-1" autocomplete="off" />
      </div>

      <!-- Name -->
      <div>
        <label :class="['block text-sm font-semibold mb-1.5', isLight ? 'text-slate-700' : 'text-slate-200']">
          ชื่อ <span class="text-red-400">*</span>
        </label>
        <input
          v-model="name"
          type="text"
          required
          maxlength="100"
          placeholder="ชื่อของคุณ"
          :class="[
            'w-full px-4 py-2.5 rounded-xl border text-sm transition-all outline-none focus:ring-2',
            isLight
              ? 'bg-slate-50 border-slate-200 text-slate-800 placeholder-slate-400 focus:border-blue-400 focus:ring-blue-100'
              : 'bg-white/5 border-white/15 text-white placeholder-slate-400 focus:border-white/40 focus:ring-white/10',
          ]"
        />
      </div>

      <!-- Email -->
      <div>
        <label :class="['block text-sm font-semibold mb-1.5', isLight ? 'text-slate-700' : 'text-slate-200']">
          อีเมล
          <span :class="['text-xs font-normal ml-1', isLight ? 'text-slate-400' : 'text-slate-400']">(ไม่บังคับ)</span>
        </label>
        <input
          v-model="email"
          type="email"
          maxlength="200"
          placeholder="example@email.com"
          :class="[
            'w-full px-4 py-2.5 rounded-xl border text-sm transition-all outline-none focus:ring-2',
            isLight
              ? 'bg-slate-50 border-slate-200 text-slate-800 placeholder-slate-400 focus:border-blue-400 focus:ring-blue-100'
              : 'bg-white/5 border-white/15 text-white placeholder-slate-400 focus:border-white/40 focus:ring-white/10',
          ]"
        />
        <p :class="['text-xs mt-1.5 flex items-center gap-1', isLight ? 'text-slate-400' : 'text-slate-400']">
          <svg class="w-3.5 h-3.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
          หากต้องการให้ตอบกลับ กรุณาระบุอีเมลของคุณ
        </p>
      </div>

      <!-- Message -->
      <div>
        <label :class="['block text-sm font-semibold mb-1.5', isLight ? 'text-slate-700' : 'text-slate-200']">
          ข้อความ <span class="text-red-400">*</span>
        </label>
        <textarea
          v-model="message"
          required
          rows="5"
          maxlength="2000"
          placeholder="พิมพ์ข้อความของคุณที่นี่..."
          :class="[
            'w-full px-4 py-2.5 rounded-xl border text-sm transition-all outline-none focus:ring-2 resize-none leading-relaxed',
            isLight
              ? 'bg-slate-50 border-slate-200 text-slate-800 placeholder-slate-400 focus:border-blue-400 focus:ring-blue-100'
              : 'bg-white/5 border-white/15 text-white placeholder-slate-400 focus:border-white/40 focus:ring-white/10',
          ]"
        ></textarea>
        <p :class="['text-right text-xs mt-1', isLight ? 'text-slate-400' : 'text-slate-500']">
          {{ message.length }}/2000
        </p>
      </div>

      <!-- CAPTCHA -->
      <div :class="[
        'rounded-xl border p-4',
        isLight ? 'bg-slate-50 border-slate-200' : 'bg-white/5 border-white/10',
      ]">
        <label :class="['block text-sm font-semibold mb-3 flex items-center gap-2', isLight ? 'text-slate-700' : 'text-slate-200']">
          <svg class="w-4 h-4 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
          ยืนยันตัวตน (กันบอท)
        </label>
        <div class="flex items-center gap-3 flex-wrap">
          <div :class="[
            'flex items-center justify-center px-5 py-2.5 rounded-xl font-bold text-xl tracking-widest select-none',
            isLight ? 'bg-white border border-slate-200 text-slate-700 shadow-sm' : 'bg-white/10 border border-white/15 text-white',
          ]">
            {{ captchaA }} + {{ captchaB }} = ?
          </div>
          <input
            v-model="captchaAns"
            type="number"
            required
            min="0"
            max="99"
            placeholder="คำตอบ"
            :class="[
              'w-24 px-3 py-2.5 rounded-xl border text-sm text-center font-bold transition-all outline-none focus:ring-2',
              captchaAns
                ? captchaCorrect
                  ? (isLight ? 'border-emerald-400 bg-emerald-50 text-emerald-700 focus:ring-emerald-100' : 'border-emerald-400 bg-emerald-500/10 text-emerald-300 focus:ring-emerald-400/20')
                  : (isLight ? 'border-red-400 bg-red-50 text-red-700 focus:ring-red-100' : 'border-red-400 bg-red-500/10 text-red-300 focus:ring-red-400/20')
                : (isLight ? 'border-slate-200 bg-slate-50 text-slate-800 focus:border-blue-400 focus:ring-blue-100' : 'border-white/15 bg-white/5 text-white focus:border-white/40 focus:ring-white/10'),
            ]"
          />
          <span v-if="captchaAns" class="text-lg">
            {{ captchaCorrect ? '✅' : '❌' }}
          </span>
          <button
            type="button"
            @click="newCaptcha"
            :class="['text-xs px-3 py-2 rounded-lg transition-colors', isLight ? 'text-slate-400 hover:text-slate-600 hover:bg-slate-200' : 'text-slate-400 hover:text-white hover:bg-white/10']"
            title="เปลี่ยนโจทย์ใหม่"
          >
            🔄 โจทย์ใหม่
          </button>
        </div>
      </div>

      <!-- Submit -->
      <button
        type="submit"
        :disabled="submitting || !name.trim() || !message.trim() || !captchaCorrect"
        :class="[
          'w-full py-3 px-6 rounded-xl font-semibold text-sm transition-all flex items-center justify-center gap-2',
          submitting || !name.trim() || !message.trim() || !captchaCorrect
            ? 'opacity-50 cursor-not-allowed bg-slate-300 text-slate-500'
            : 'text-white shadow-lg hover:shadow-xl hover:-translate-y-0.5 bg-gradient-to-r from-blue-500 to-cyan-400',
        ]"
      >
        <svg v-if="!submitting" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>
        <svg v-else class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
        {{ submitting ? 'กำลังส่ง...' : 'ส่งข้อความ' }}
      </button>
    </form>

  </div>
</template>

<style scoped>
.toast-enter-active, .toast-leave-active { transition: all 0.3s cubic-bezier(0.4,0,0.2,1); }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(-16px); }
</style>
