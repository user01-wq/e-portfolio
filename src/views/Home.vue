<script setup>
import { ref, onMounted, onBeforeUnmount, computed, watch, nextTick, inject } from 'vue'
import { supabase } from '../lib/supabase'
import ProjectCard from '../components/ProjectCard.vue'

const isLight = inject('isLight', ref(false))

const profile = ref({
  full_name: '',
  greeting: 'สวัสดีค่ะ ฉัน',
  bio: '',
  avatar_url: '',
  portfolio_btn_text: 'คลังสื่อการสอน',
  show_profile: true,
  show_banners: true,
})
const banners          = ref([])
const featuredProjects = ref([])
const loading          = ref(true)
const stats            = ref({ projects: 0, experiences: 0, educations: 0 })

// ── Slideshow state ──────────────────────────────────────────────────────────
const currentSlide = ref(0)
const isPaused     = ref(false)
const videoRefs    = ref({})
const slideDir     = ref(1)    // 1 = forward, -1 = backward
const randomEffect = ref('fade')
const EFFECTS      = ['fade', 'slide', 'zoom', 'flip']
let advanceTimer   = null
const IMAGE_INTERVAL = 6000
const EMBED_INTERVAL = 12000

onMounted(async () => {
  try {
    const [profileRes, bannerRes, projRes, projCountRes, expCountRes, eduCountRes] = await Promise.all([
      supabase.from('profiles').select('*').limit(1).single(),
      supabase.from('banners').select('*')
        .order('is_pinned',   { ascending: false })
        .order('sort_order',  { ascending: true })
        .order('created_at',  { ascending: false }),
      supabase.from('projects').select('id, title, description, image_url, media_type, link, embed_code, file_path, likes, views')
        .order('created_at', { ascending: false }).limit(6),
      supabase.from('projects').select('id',    { count: 'exact', head: true }),
      supabase.from('experiences').select('id', { count: 'exact', head: true }),
      supabase.from('educations').select('id',  { count: 'exact', head: true }),
    ])

    if (profileRes.data) {
      profile.value = { ...profile.value, ...profileRes.data }
    } else {
      profile.value = {
        full_name: 'คุณครูใจดี',
        greeting: 'สวัสดีค่ะ ฉัน',
        bio: 'ครูผู้มีความมุ่งมั่นและมีประสบการณ์กว่า 10 ปี ในการสร้างบรรยากาศการเรียนรู้ที่ครอบคลุมและน่าสนใจ',
        avatar_url: 'https://ui-avatars.com/api/?name=คุณครู+ใจดี&size=256&background=0D8ABC&color=fff',
        portfolio_btn_text: 'คลังสื่อการสอน',
        show_profile: true,
        show_banners: true,
      }
    }

    if (bannerRes.data)  banners.value          = bannerRes.data.filter(b => b.is_visible !== false)
    if (projRes.data)    featuredProjects.value = projRes.data

    stats.value = {
      projects:    projCountRes.count  || 0,
      experiences: expCountRes.count   || 0,
      educations:  eduCountRes.count   || 0,
    }
  } catch (e) {
    console.error('Error fetching home data:', e.message)
  } finally {
    loading.value = false
  }

  await nextTick()
  scheduleNext()
})

onBeforeUnmount(() => clearTimer())

function clearTimer() {
  if (advanceTimer) { clearTimeout(advanceTimer); advanceTimer = null }
}

// ── Solo + transition computed ────────────────────────────────────────────────
const displayBanners = computed(() => {
  if (profile.value.solo_banner_id) {
    const solo = banners.value.find(b => b.id === profile.value.solo_banner_id)
    return solo ? [solo] : banners.value
  }
  return banners.value
})

const currentBanner = computed(() => displayBanners.value[currentSlide.value] || null)

const activeTransitionName = computed(() => {
  let eff = profile.value.banner_effect || 'fade'
  if (eff === 'random') eff = randomEffect.value
  if (eff === 'slide') return slideDir.value >= 0 ? 'banner-slide-fwd' : 'banner-slide-bwd'
  return 'banner-' + eff
})

function pickRandom() {
  if ((profile.value.banner_effect || 'fade') === 'random') {
    randomEffect.value = EFFECTS[Math.floor(Math.random() * EFFECTS.length)]
  }
}

function nextSlide() {
  if (displayBanners.value.length < 2) return
  slideDir.value = 1; pickRandom()
  currentSlide.value = (currentSlide.value + 1) % displayBanners.value.length
}
function prevSlide() {
  if (displayBanners.value.length < 2) return
  slideDir.value = -1; pickRandom()
  currentSlide.value = (currentSlide.value - 1 + displayBanners.value.length) % displayBanners.value.length
}
function goSlide(i) {
  slideDir.value = i >= currentSlide.value ? 1 : -1; pickRandom()
  currentSlide.value = i
}

function scheduleNext() {
  clearTimer()
  if (displayBanners.value.length < 2) return
  if (isPaused.value) return

  const current = currentBanner.value
  if (!current) return

  for (const [id, vid] of Object.entries(videoRefs.value)) {
    if (vid && id !== current.id) { vid.pause(); vid.currentTime = 0 }
  }

  if (current.media_type === 'video') {
    const v = videoRefs.value[current.id]
    if (v) {
      v.currentTime = 0
      const p = v.play()
      if (p && p.catch) p.catch(() => { advanceTimer = setTimeout(nextSlide, IMAGE_INTERVAL) })
    } else {
      advanceTimer = setTimeout(nextSlide, IMAGE_INTERVAL)
    }
  } else if (current.media_type === 'google_slide' || current.media_type === 'canva') {
    advanceTimer = setTimeout(nextSlide, EMBED_INTERVAL)
  } else {
    advanceTimer = setTimeout(nextSlide, IMAGE_INTERVAL)
  }
}

function onVideoEnded(id) {
  if (!currentBanner.value || currentBanner.value.id !== id) return
  if (isPaused.value) return
  nextSlide()
}

function onMouseEnter() {
  isPaused.value = true
  clearTimer()
  if (currentBanner.value?.media_type === 'video') {
    const v = videoRefs.value[currentBanner.value.id]
    if (v) v.pause()
  }
}

function onMouseLeave() {
  isPaused.value = false
  if (currentBanner.value?.media_type === 'video') {
    const v = videoRefs.value[currentBanner.value.id]
    if (v) { v.play().catch(() => {}) }
  } else {
    scheduleNext()
  }
}

watch(currentSlide, () => { nextTick(scheduleNext) })
watch(displayBanners, () => { currentSlide.value = 0; nextTick(scheduleNext) })

const hasBanners      = computed(() => (profile.value.show_banners ?? true) && banners.value.length > 0)
const showProfileCard = computed(() => profile.value.show_profile !== false)
const sectionTitle    = computed(() => profile.value.portfolio_title    || 'สื่อการสอนล่าสุด')
const sectionBtnText  = computed(() => profile.value.portfolio_btn_text || 'คลังสื่อการสอน')

// ── Social links ─────────────────────────────────────────────────────────────
const SOCIAL_PLATFORMS = [
  { key: 'website',   label: 'เว็บไซต์',    color: '#6366f1' },
  { key: 'facebook',  label: 'Facebook',    color: '#1877F2' },
  { key: 'youtube',   label: 'YouTube',     color: '#FF0000' },
  { key: 'tiktok',    label: 'TikTok',      color: '#010101' },
  { key: 'instagram', label: 'Instagram',   color: '#E1306C' },
  { key: 'twitter',   label: 'X (Twitter)', color: '#000000' },
  { key: 'line',      label: 'LINE',        color: '#06C755' },
  { key: 'linkedin',  label: 'LinkedIn',    color: '#0A66C2' },
  { key: 'github',    label: 'GitHub',      color: '#24292e' },
]
const SOCIAL_SVGS = {
  website:   'M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2zm6.926 6h-2.372a15.77 15.77 0 0 0-1.534-3.501A8.027 8.027 0 0 1 18.926 8zM12 4.044c.782.912 1.545 2.26 2.03 3.956H9.97C10.455 6.304 11.218 4.956 12 4.044zM4.188 14A8.187 8.187 0 0 1 4 12c0-.688.097-1.35.244-2H7.7c-.09.65-.145 1.316-.145 2s.055 1.35.145 2H4.188zm.886 2h2.372a15.77 15.77 0 0 0 1.534 3.501A8.028 8.028 0 0 1 5.074 16zm2.372-8H5.074a8.027 8.027 0 0 1 3.906-3.501A15.77 15.77 0 0 0 7.446 8zM12 19.956c-.782-.912-1.545-2.26-2.03-3.956h4.06c-.485 1.696-1.248 3.044-2.03 3.956zM14.37 14H9.63c-.098-.646-.159-1.314-.159-2s.061-1.354.159-2h4.74c.098.646.159 1.314.159 2s-.061 1.354-.159 2zm.6 5.501A15.77 15.77 0 0 0 16.504 16h2.372a8.028 8.028 0 0 1-3.906 3.501zM16.3 14c.09-.65.145-1.316.145-2s-.055-1.35-.145-2h3.456c.147.65.244 1.312.244 2s-.097 1.35-.244 2H16.3z',
  facebook:  'M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z',
  youtube:   'M23.495 6.205a3.007 3.007 0 0 0-2.088-2.088c-1.87-.501-9.396-.501-9.396-.501s-7.507-.01-9.396.501A3.007 3.007 0 0 0 .527 6.205a31.247 31.247 0 0 0-.522 5.805 31.247 31.247 0 0 0 .522 5.783 3.007 3.007 0 0 0 2.088 2.088c1.868.502 9.396.502 9.396.502s7.506 0 9.396-.502a3.007 3.007 0 0 0 2.088-2.088 31.247 31.247 0 0 0 .5-5.783 31.247 31.247 0 0 0-.5-5.805zM9.609 15.601V8.408l6.264 3.602z',
  tiktok:    'M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z',
  instagram: 'M12 0C8.74 0 8.333.015 7.053.072 5.775.132 4.905.333 4.14.63c-.789.306-1.459.717-2.126 1.384S.935 3.35.63 4.14C.333 4.905.131 5.775.072 7.053.012 8.333 0 8.74 0 12c0 3.259.014 3.668.072 4.948.06 1.277.261 2.148.558 2.913.306.788.717 1.459 1.384 2.126.667.666 1.336 1.079 2.126 1.384.766.296 1.636.499 2.913.558C8.333 23.988 8.74 24 12 24c3.259 0 3.668-.014 4.948-.072 1.277-.06 2.148-.262 2.913-.558.788-.306 1.459-.718 2.126-1.384.666-.667 1.079-1.335 1.384-2.126.296-.765.499-1.636.558-2.913.06-1.28.072-1.689.072-4.948 0-3.259-.014-3.667-.072-4.947-.06-1.277-.262-2.149-.558-2.913-.306-.789-.718-1.459-1.384-2.126C21.319 1.347 20.651.935 19.86.63c-.765-.297-1.636-.499-2.913-.558C15.667.012 15.26 0 12 0zm0 2.16c3.203 0 3.585.016 4.85.071 1.17.055 1.805.249 2.227.415.562.217.96.477 1.382.896.419.42.679.819.896 1.381.164.422.36 1.057.413 2.227.057 1.266.07 1.646.07 4.85s-.015 3.585-.074 4.85c-.061 1.17-.256 1.805-.421 2.227-.224.562-.479.96-.899 1.382-.419.419-.824.679-1.38.896-.42.164-1.065.36-2.235.413-1.274.057-1.649.07-4.859.07-3.211 0-3.586-.015-4.859-.074-1.171-.061-1.816-.256-2.236-.421-.569-.224-.96-.479-1.379-.899-.421-.419-.69-.824-.9-1.38-.165-.42-.359-1.065-.42-2.235-.045-1.26-.061-1.649-.061-4.844 0-3.196.016-3.586.061-4.861.061-1.17.255-1.814.42-2.234.21-.57.479-.96.9-1.381.419-.419.81-.689 1.379-.898.42-.166 1.051-.361 2.221-.421 1.275-.045 1.65-.06 4.859-.06l.045.03zm0 3.678c-3.405 0-6.162 2.76-6.162 6.162 0 3.405 2.76 6.162 6.162 6.162 3.405 0 6.162-2.76 6.162-6.162 0-3.405-2.76-6.162-6.162-6.162zM12 16c-2.21 0-4-1.79-4-4s1.79-4 4-4 4 1.79 4 4-1.79 4-4 4zm7.846-10.405c0 .795-.646 1.44-1.44 1.44-.795 0-1.44-.646-1.44-1.44 0-.794.646-1.439 1.44-1.439.793-.001 1.44.645 1.44 1.439z',
  twitter:   'M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.741l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z',
  line:      'M19.365 9.863c.349 0 .63.285.63.631 0 .345-.281.63-.63.63H17.61v1.125h1.755c.349 0 .63.283.63.63 0 .344-.281.629-.63.629h-2.386c-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.63-.63h2.386c.346 0 .627.285.627.63 0 .349-.281.63-.63.63H17.61v1.125h1.755zm-3.855 3.016c0 .27-.174.51-.432.596-.064.021-.133.031-.199.031-.211 0-.391-.09-.51-.25l-2.443-3.317v2.94c0 .344-.279.629-.631.629-.346 0-.626-.285-.626-.629V8.108c0-.27.173-.51.43-.595.06-.023.136-.033.194-.033.195 0 .375.104.495.254l2.462 3.33V8.108c0-.345.282-.63.63-.63.345 0 .63.285.63.63v4.771zm-5.741 0c0 .344-.282.629-.631.629-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.63-.63.346 0 .628.285.628.63v4.771zm-2.466.629H4.917c-.345 0-.63-.285-.63-.629V8.108c0-.345.285-.63.63-.63.348 0 .63.285.63.63v4.141h1.756c.348 0 .629.283.629.63 0 .344-.282.629-.629.629M24 10.314C24 4.943 18.615.572 12 .572S0 4.943 0 10.314c0 4.811 4.27 8.842 10.035 9.608.391.082.923.258 1.058.59.12.301.079.766.038 1.08l-.164 1.02c-.045.301-.24 1.186 1.049.645 1.291-.539 6.916-4.078 9.436-6.975C23.176 14.393 24 12.458 24 10.314',
  linkedin:  'M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z',
  github:    'M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12',
}

const activeSocials = computed(() => {
  const links = profile.value.social_links || {}
  return SOCIAL_PLATFORMS.filter(p => {
    const e = links[p.key]
    return e?.url && e?.visible !== false
  }).map(p => ({ ...p, url: links[p.key].url }))
})

function setVideoRef(id, el) {
  if (el) videoRefs.value[id] = el
  else delete videoRefs.value[id]
}
</script>

<template>
  <div class="relative">
    <!-- Loader -->
    <div v-if="loading" class="flex justify-center items-center min-h-[60vh]">
      <div :class="['animate-spin rounded-full h-12 w-12 border-t-2 border-b-2', isLight ? 'border-slate-600' : 'border-white']"></div>
    </div>

    <template v-else>

      <!-- ════════════════ BANNER SLIDESHOW ════════════════ -->
      <section
        v-if="hasBanners"
        class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 mt-2"
        @mouseenter="onMouseEnter"
        @mouseleave="onMouseLeave"
      >
        <div
          :class="[
            'relative w-full aspect-[16/9] rounded-3xl overflow-hidden border shadow-2xl',
            isLight ? 'border-slate-200/80 bg-slate-100' : 'border-white/10 bg-slate-800/40',
          ]"
        >
          <!-- Slides — Vue transition for effect support -->
          <transition :name="activeTransitionName">
            <div v-if="currentBanner" :key="currentBanner.id" class="absolute inset-0">
              <img
                v-if="currentBanner.media_type === 'image'"
                :src="currentBanner.media_url" :alt="currentBanner.title || 'banner'"
                class="absolute inset-0 w-full h-full object-cover"
                :style="{ objectPosition: currentBanner.object_position || 'center' }"
                loading="lazy"
              />
              <video
                v-else-if="currentBanner.media_type === 'video'"
                :ref="el => setVideoRef(currentBanner.id, el)"
                :src="currentBanner.media_url"
                class="absolute inset-0 w-full h-full object-cover"
                :style="{ objectPosition: currentBanner.object_position || 'center' }"
                muted playsinline preload="metadata"
                @ended="onVideoEnded(currentBanner.id)"
              ></video>
              <iframe
                v-else-if="currentBanner.media_type === 'google_slide' || currentBanner.media_type === 'canva'"
                :src="currentBanner.media_url"
                class="absolute inset-0 w-full h-full"
                frameborder="0" allow="autoplay; fullscreen" allowfullscreen loading="lazy"
              ></iframe>

              <!-- Gradient overlay -->
              <div class="absolute inset-0 bg-gradient-to-b from-black/10 via-transparent to-black/40"></div>

              <!-- Caption bar — full width, bottom, subtle -->
              <div
                v-if="currentBanner.title || currentBanner.caption || currentBanner.link_url"
                class="absolute bottom-0 inset-x-0 z-10 bg-black/30 backdrop-blur-sm pb-6"
              >
                <div class="flex flex-col items-center text-center gap-0.5 px-6 pt-2.5 sm:px-16 sm:pt-3">
                  <div class="flex items-center justify-center gap-2 flex-wrap">
                    <span v-if="currentBanner.is_pinned" class="inline-flex items-center gap-1 px-2 py-0.5 bg-amber-400/90 text-amber-900 text-xs font-bold rounded-full">
                      <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path d="M10 2a1 1 0 011 1v1.586l3.707 3.707A1 1 0 0115 9v3a1 1 0 01-1 1h-3v4a1 1 0 01-1-1V9a1 1 0 01.293-.707L9 4.586V3a1 1 0 011-1z"/></svg>
                      ตรึงไว้
                    </span>
                    <h2 v-if="currentBanner.title" class="text-sm sm:text-base font-bold text-white leading-tight">{{ currentBanner.title }}</h2>
                  </div>
                  <p v-if="currentBanner.caption" class="text-xs sm:text-sm text-white/70 leading-snug">{{ currentBanner.caption }}</p>
                  <a v-if="currentBanner.link_url" :href="currentBanner.link_url" target="_blank" rel="noopener noreferrer"
                    class="mt-1 inline-flex items-center gap-1 px-3 py-1 bg-white/15 hover:bg-white/25 text-white text-xs font-medium rounded-lg border border-white/20 transition-all">
                    อ่านต่อ
                    <svg class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                  </a>
                </div>
              </div>
            </div>
          </transition>

          <!-- Prev / Next -->
          <button v-if="displayBanners.length > 1" @click="prevSlide"
            class="absolute left-2 sm:left-4 top-1/2 -translate-y-1/2 z-20 w-9 h-9 sm:w-11 sm:h-11 rounded-full bg-black/30 hover:bg-black/55 backdrop-blur-md text-white border border-white/20 transition-all hover:scale-110" aria-label="ก่อนหน้า">
            <svg class="h-5 w-5 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/></svg>
          </button>
          <button v-if="displayBanners.length > 1" @click="nextSlide"
            class="absolute right-2 sm:right-4 top-1/2 -translate-y-1/2 z-20 w-9 h-9 sm:w-11 sm:h-11 rounded-full bg-black/30 hover:bg-black/55 backdrop-blur-md text-white border border-white/20 transition-all hover:scale-110" aria-label="ถัดไป">
            <svg class="h-5 w-5 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/></svg>
          </button>

          <!-- Dots — วางชิดล่าง ทับบน padding ของ caption bar -->
          <div v-if="displayBanners.length > 1" class="absolute bottom-0 inset-x-0 z-20 flex justify-center pb-2 pointer-events-none">
            <div class="flex items-center gap-1.5 pointer-events-auto">
              <button v-for="(b, i) in displayBanners" :key="b.id + '-dot'" @click="goSlide(i)"
                :class="['h-1.5 rounded-full transition-all duration-300 border border-white/30', i === currentSlide ? 'w-7 bg-white' : 'w-1.5 bg-white/40 hover:bg-white/60']"
                :aria-label="`สไลด์ที่ ${i+1}`"></button>
            </div>
          </div>
        </div>
      </section>

      <!-- ════════════════ PROFILE CARD (compact) ════════════════ -->
      <section
        v-if="showProfileCard"
        :class="['relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8', hasBanners ? '-mt-10 sm:-mt-14 z-20' : 'mt-8']"
      >
        <div
          :class="[
            'relative backdrop-blur-2xl rounded-2xl border shadow-xl p-5 sm:p-7 overflow-hidden',
            isLight ? 'bg-white/80 border-slate-200/80' : 'bg-white/10 border-white/15',
          ]"
        >
          <div class="absolute -top-8 -right-8 w-32 h-32 bg-white/5 rounded-full blur-2xl pointer-events-none"></div>
          <div class="absolute -bottom-8 -left-8 w-32 h-32 bg-white/5 rounded-full blur-2xl pointer-events-none"></div>

          <div class="relative flex flex-col sm:flex-row items-center sm:items-start gap-5">

            <!-- Avatar (compact) -->
            <div class="relative flex-shrink-0">
              <div :class="['absolute -inset-1.5 rounded-full blur-md opacity-80', isLight ? 'bg-gradient-to-tr from-slate-300/60 to-slate-100/30' : 'bg-gradient-to-tr from-white/25 to-white/5']"></div>
              <img
                :class="['relative h-24 w-24 sm:h-28 sm:w-28 rounded-full object-cover shadow-xl', isLight ? 'border-2 border-slate-300/70' : 'border-2 border-white/30']"
                :src="profile.avatar_url || 'https://via.placeholder.com/256'"
                :alt="profile.full_name"
              />
              <span :class="['absolute bottom-1 right-1 w-4 h-4 bg-emerald-400 rounded-full border-2 shadow', isLight ? 'border-white' : 'border-slate-900']"></span>
            </div>

            <!-- Info -->
            <div class="flex-grow text-center sm:text-left space-y-2 min-w-0">
              <div
                :class="[
                  'inline-block px-2.5 py-0.5 rounded-full text-xs font-medium border',
                  isLight ? 'bg-slate-100 text-slate-600 border-slate-200' : 'bg-white/10 text-white/75 border-white/10',
                ]"
              >
                ✨ แฟ้มสะสมผลงานวิชาชีพ
              </div>
              <h1 :class="['font-extrabold tracking-tight leading-tight text-2xl sm:text-3xl', isLight ? 'text-slate-800' : 'text-white']">
                {{ profile.greeting || 'สวัสดีค่ะ ฉัน' }}
                <span :class="isLight ? 'text-slate-500' : 'text-white/80'">{{ profile.full_name || 'คุณครู' }}</span>
              </h1>
              <div
                :class="['text-sm sm:text-base leading-relaxed font-light prose-glass line-clamp-2', isLight ? 'text-slate-600' : 'text-slate-200/85']"
                v-html="profile.bio || 'ยินดีต้อนรับสู่แฟ้มสะสมผลงานวิชาชีพของฉัน'"
              ></div>

              <!-- Stats + CTA row -->
              <div class="pt-3 flex flex-wrap items-center justify-center sm:justify-start gap-3">
                <!-- Mini stats -->
                <div
                  :class="[
                    'flex items-center gap-3 px-3 py-1.5 rounded-xl border text-xs',
                    isLight ? 'bg-slate-100 border-slate-200 text-slate-500' : 'bg-white/8 border-white/10 text-slate-300',
                  ]"
                >
                  <span><strong :class="['font-bold', isLight ? 'text-slate-800' : 'text-white']">{{ stats.projects }}</strong> สื่อ</span>
                  <span class="opacity-30">|</span>
                  <span><strong :class="['font-bold', isLight ? 'text-slate-800' : 'text-white']">{{ stats.experiences }}</strong> ประสบการณ์</span>
                  <span class="opacity-30">|</span>
                  <span><strong :class="['font-bold', isLight ? 'text-slate-800' : 'text-white']">{{ stats.educations }}</strong> การศึกษา</span>
                </div>
                <!-- CTA buttons -->
                <router-link to="/resume"
                  :class="[
                    'inline-flex items-center gap-1.5 px-4 py-2 border text-sm font-medium rounded-xl backdrop-blur-md shadow transition-all hover:-translate-y-0.5',
                    isLight
                      ? 'border-slate-300 text-slate-700 bg-white hover:bg-slate-50'
                      : 'border-white/20 text-white bg-white/10 hover:bg-white/20',
                  ]"
                >
                  <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
                  ดูประวัติ
                </router-link>
                <router-link to="/projects"
                  :class="[
                    'inline-flex items-center gap-1.5 px-4 py-2 border border-transparent text-sm font-semibold rounded-xl shadow transition-all hover:-translate-y-0.5',
                    isLight
                      ? 'text-white bg-slate-700 hover:bg-slate-800'
                      : 'text-slate-900 bg-white hover:bg-slate-100',
                  ]"
                >
                  <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>
                  {{ profile.portfolio_btn_text || 'คลังสื่อการสอน' }}
                </router-link>
              </div>

            </div>

            <!-- Social icons: mobile only (row below buttons) -->
            <div v-if="activeSocials.length" class="sm:hidden flex flex-wrap justify-center gap-2 pt-1">
              <a
                v-for="s in activeSocials" :key="s.key"
                :href="s.url" target="_blank" rel="noopener noreferrer"
                :title="s.label"
                class="w-9 h-9 rounded-full flex items-center justify-center border transition-all duration-200 hover:scale-110 hover:shadow-md"
                :style="{ backgroundColor: s.color + '20', color: s.color, borderColor: s.color + '40' }"
              >
                <svg viewBox="0 0 24 24" class="w-4 h-4" fill="currentColor">
                  <path :d="SOCIAL_SVGS[s.key]" />
                </svg>
              </a>
            </div>
            <!-- Social icons: desktop only — 4-per-row grid (flex sibling) -->
            <div
              v-if="activeSocials.length"
              class="hidden sm:grid grid-cols-4 gap-2 flex-shrink-0 self-center pl-5"
              :class="isLight ? 'border-l border-slate-200/80' : 'border-l border-white/10'"
            >
              <a
                v-for="s in activeSocials" :key="s.key"
                :href="s.url" target="_blank" rel="noopener noreferrer"
                :title="s.label"
                class="w-9 h-9 rounded-full flex items-center justify-center border transition-all duration-200 hover:scale-110 hover:shadow-lg"
                :style="{ backgroundColor: s.color + '18', color: s.color, borderColor: s.color + '35' }"
              >
                <svg viewBox="0 0 24 24" class="w-4 h-4" fill="currentColor">
                  <path :d="SOCIAL_SVGS[s.key]" />
                </svg>
              </a>
            </div>
          </div>
        </div>
      </section>

      <!-- ════════════════ PROJECTS GALLERY (3×2) ════════════════ -->
      <section v-if="featuredProjects.length > 0" class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 mt-10 pb-14">
        <!-- Section header -->
        <div class="flex items-center justify-between mb-5">
          <div>
            <h2 :class="['text-lg sm:text-xl font-bold', isLight ? 'text-slate-800' : 'text-white']">{{ sectionTitle }}</h2>
            <p :class="['text-xs mt-0.5', isLight ? 'text-slate-500' : 'text-slate-400']">รายการล่าสุด {{ featuredProjects.length }} รายการ จากทั้งหมด {{ stats.projects }}</p>
          </div>
          <router-link to="/projects"
            :class="[
              'inline-flex items-center gap-1.5 px-4 py-2 text-sm font-medium rounded-xl border backdrop-blur-md transition-all hover:-translate-y-0.5 shadow',
              isLight
                ? 'text-slate-700 bg-white border-slate-200 hover:bg-slate-50'
                : 'text-white bg-white/10 hover:bg-white/20 border-white/15',
            ]"
          >
            ดูทั้งหมด
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
          </router-link>
        </div>

        <!-- 3-column grid using ProjectCard -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <ProjectCard v-for="proj in featuredProjects" :key="proj.id" :project="proj" />
        </div>

        <!-- View all button -->
        <div class="mt-7 flex justify-center">
          <router-link to="/projects"
            :class="[
              'inline-flex items-center gap-2 px-6 py-2.5 text-sm font-semibold rounded-xl shadow-lg transition-all hover:-translate-y-0.5',
              isLight
                ? 'text-white bg-slate-700 hover:bg-slate-800'
                : 'text-slate-900 bg-white hover:bg-slate-100',
            ]"
          >
            ดู{{ sectionBtnText }}ทั้งหมด ({{ stats.projects }})
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
          </router-link>
        </div>
      </section>

      <!-- Spacer when no sections -->
      <div v-if="!hasBanners && !showProfileCard && featuredProjects.length === 0" :class="['py-24 text-center', isLight ? 'text-slate-400' : 'text-slate-400']">
        <p>กำลังโหลดข้อมูล...</p>
      </div>

    </template>
  </div>
</template>

<style>
.prose-glass p { margin-bottom: 0.75rem; }
.prose-glass strong, .prose-glass b { color: inherit; font-weight: 700; }
.prose-glass em, .prose-glass i { font-style: italic; }
.prose-glass img { border-radius: 0.75rem; max-height: 360px; object-fit: cover; margin: 0.75rem 0; border: 1px solid rgba(255,255,255,0.2); }
.prose-glass ul { list-style-type: disc; padding-left: 1.5rem; margin-bottom: 0.75rem; }
.prose-glass ol { list-style-type: decimal; padding-left: 1.5rem; margin-bottom: 0.75rem; }
.prose-glass li { margin-bottom: 0.25rem; }

.line-clamp-2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }

/* ── Banner Transition Effects ──────────────────────────────────────────────── */

/* Fade — smooth cross-dissolve */
.banner-fade-enter-active,
.banner-fade-leave-active { transition: opacity 0.75s ease; }
.banner-fade-enter-active { z-index: 1; position: absolute; inset: 0; }
.banner-fade-enter-from,
.banner-fade-leave-to     { opacity: 0; }

/* Slide Forward — new banner slides in from right while old exits left */
.banner-slide-fwd-enter-active,
.banner-slide-fwd-leave-active { transition: transform 0.65s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.65s ease; }
.banner-slide-fwd-enter-active { z-index: 1; position: absolute; inset: 0; }
.banner-slide-fwd-enter-from   { transform: translateX(100%); opacity: 0.85; }
.banner-slide-fwd-leave-to     { transform: translateX(-35%); opacity: 0; }

/* Slide Backward — new banner slides in from left while old exits right */
.banner-slide-bwd-enter-active,
.banner-slide-bwd-leave-active { transition: transform 0.65s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.65s ease; }
.banner-slide-bwd-enter-active { z-index: 1; position: absolute; inset: 0; }
.banner-slide-bwd-enter-from   { transform: translateX(-100%); opacity: 0.85; }
.banner-slide-bwd-leave-to     { transform: translateX(35%); opacity: 0; }

/* Zoom — Ken Burns style: new slide zooms in while old fades & shrinks */
.banner-zoom-enter-active,
.banner-zoom-leave-active { transition: transform 0.8s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.8s ease; }
.banner-zoom-enter-active { z-index: 1; position: absolute; inset: 0; }
.banner-zoom-enter-from   { transform: scale(1.14); opacity: 0; }
.banner-zoom-leave-to     { transform: scale(0.88); opacity: 0; }

/* Flip — 3-D perspective rotation around Y axis */
.banner-flip-enter-active,
.banner-flip-leave-active { transition: transform 0.65s ease, opacity 0.65s ease; }
.banner-flip-enter-active { z-index: 1; position: absolute; inset: 0; }
.banner-flip-enter-from   { transform: perspective(1400px) rotateY(22deg) scale(0.96); opacity: 0; }
.banner-flip-leave-to     { transform: perspective(1400px) rotateY(-22deg) scale(0.96); opacity: 0; }
</style>
