<script setup>
import { ref, onMounted, onUnmounted, inject } from 'vue'
import { supabase } from '../lib/supabase'

const isLight = inject('isLight', ref(false))

const onlineCount = ref(1)
const pageViews   = ref(0)
const footerText  = ref('')
const profileName = ref('')
const year        = new Date().getFullYear()

let presence = null

onMounted(async () => {
  // ── 1. Fetch profile name, footer_text, current page_views ───────────────
  try {
    const { data } = await supabase
      .from('profiles')
      .select('full_name, footer_text, page_views')
      .limit(1).single()
    if (data) {
      profileName.value = data.full_name  || ''
      footerText.value  = data.footer_text || ''
      pageViews.value   = Number(data.page_views) || 0
    }
  } catch { /* no profile yet */ }

  // ── 2. Increment page views once per browser session ─────────────────────
  if (!sessionStorage.getItem('_spv')) {
    sessionStorage.setItem('_spv', '1')
    try {
      await supabase.rpc('increment_site_page_views')
      // Re-fetch ค่าจริงจาก DB แทนการพึ่งค่าที่ RPC return
      const { data: pv } = await supabase
        .from('profiles').select('page_views').limit(1).single()
      if (pv?.page_views != null) pageViews.value = Number(pv.page_views)
    } catch { /* ignore */ }
  }

  // ── 3. Supabase Realtime Presence — track online visitors ─────────────────
  const vid = sessionStorage.getItem('_svid') || crypto.randomUUID()
  sessionStorage.setItem('_svid', vid)

  presence = supabase.channel('site-online-users', {
    config: { presence: { key: vid } },
  })

  presence
    .on('presence', { event: 'sync' }, () => {
      const state = presence.presenceState()
      const count = Object.keys(state).length
      onlineCount.value = count > 0 ? count : 1
    })
    .subscribe(async (status) => {
      if (status === 'SUBSCRIBED') {
        await presence.track({ ts: Date.now() })
      }
    })
})

onUnmounted(async () => {
  if (presence) {
    await presence.untrack()
    supabase.removeChannel(presence)
    presence = null
  }
})

// ── Number formatter ──────────────────────────────────────────────────────────
function fmt(n) {
  if (!n || n < 0) return '0'
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + 'M'
  if (n >= 10_000)    return (n / 1_000).toFixed(1)    + 'K'
  return n.toLocaleString('th-TH')
}
</script>

<template>
  <footer
    :class="[
      'relative z-10 mt-auto',
      isLight
        ? 'bg-white/70 backdrop-blur-xl border-t border-slate-200/80'
        : 'bg-black/25 backdrop-blur-xl border-t border-white/8',
    ]"
  >

    <!-- ── Stats Bar ─────────────────────────────────────────────────────── -->
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-5">
      <div class="flex flex-col sm:flex-row items-center justify-center gap-3">

        <!-- Online users card -->
        <div
          :class="[
            'flex items-center gap-3 px-5 py-3 rounded-2xl border text-sm font-medium transition-all duration-300',
            isLight
              ? 'bg-emerald-50 border-emerald-200/80 text-emerald-800 shadow-sm shadow-emerald-100'
              : 'bg-emerald-500/10 border-emerald-500/20 text-emerald-300 shadow-sm shadow-emerald-900/20',
          ]"
        >
          <!-- Animated pulse dot -->
          <span class="relative flex h-3 w-3 flex-shrink-0">
            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-60"></span>
            <span class="relative inline-flex rounded-full h-3 w-3 bg-emerald-500 shadow-sm"></span>
          </span>
          <span class="flex items-baseline gap-1.5">
            <span
              :class="['text-2xl font-extrabold tabular-nums leading-none', isLight ? 'text-emerald-700' : 'text-emerald-300']"
            >{{ onlineCount }}</span>
            <span :class="['text-xs font-normal', isLight ? 'text-emerald-600/80' : 'text-emerald-400/80']">
              คนกำลังออนไลน์ขณะนี้
            </span>
          </span>
        </div>

        <!-- Separator -->
        <div
          :class="[
            'hidden sm:flex items-center gap-1.5',
            isLight ? 'text-slate-300' : 'text-slate-600',
          ]"
        >
          <span class="w-8 h-px" :class="isLight ? 'bg-slate-200' : 'bg-slate-700'"></span>
          <svg class="w-3.5 h-3.5 opacity-50" fill="currentColor" viewBox="0 0 24 24">
            <circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/>
          </svg>
          <span class="w-8 h-px" :class="isLight ? 'bg-slate-200' : 'bg-slate-700'"></span>
        </div>

        <!-- Page views card -->
        <div
          :class="[
            'flex items-center gap-3 px-5 py-3 rounded-2xl border text-sm font-medium transition-all duration-300',
            isLight
              ? 'bg-blue-50 border-blue-200/80 text-blue-800 shadow-sm shadow-blue-100'
              : 'bg-blue-500/10 border-blue-500/20 text-blue-300 shadow-sm shadow-blue-900/20',
          ]"
        >
          <!-- Eye icon with subtle ring -->
          <div
            :class="[
              'w-7 h-7 rounded-lg flex items-center justify-center flex-shrink-0',
              isLight ? 'bg-blue-100 text-blue-600' : 'bg-blue-500/15 text-blue-400',
            ]"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
              <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
            </svg>
          </div>
          <span class="flex items-baseline gap-1.5">
            <span
              :class="['text-2xl font-extrabold tabular-nums leading-none', isLight ? 'text-blue-700' : 'text-blue-300']"
            >{{ fmt(pageViews) }}</span>
            <span :class="['text-xs font-normal', isLight ? 'text-blue-600/80' : 'text-blue-400/80']">
              ยอดเข้าชมทั้งหมด
            </span>
          </span>
        </div>

      </div>
    </div>

    <!-- ── Copyright bar ─────────────────────────────────────────────────── -->
    <div
      :class="[
        'border-t',
        isLight ? 'border-slate-200/60 bg-white/30' : 'border-white/5 bg-black/10',
      ]"
    >
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-3 flex flex-col sm:flex-row items-center justify-between gap-1">
        <p :class="['text-xs', isLight ? 'text-slate-400' : 'text-slate-500']">
          {{
            footerText ||
            `© ${year} แฟ้มสะสมผลงานวิชาชีพ${profileName ? ' · ' + profileName : ''}`
          }}
        </p>
        <p :class="['text-xs flex items-center gap-1', isLight ? 'text-slate-300' : 'text-slate-600']">
          <span :class="['font-medium', isLight ? 'text-slate-400' : 'text-slate-500']">Dev © Winai Nunkratok</span>
        </p>
      </div>
    </div>

  </footer>
</template>
