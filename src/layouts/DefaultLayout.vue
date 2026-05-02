<script setup>
import { onMounted, computed, ref, watch, provide } from 'vue'
import { useRoute } from 'vue-router'
import { useTheme } from '../composables/useTheme'
import SiteFooter from '../components/SiteFooter.vue'

const { currentTheme, siteName, logoUrl, footerText, isMourning, portfolioBtnText, navVisibility, loadTheme } = useTheme()
const route = useRoute()
const mobileOpen = ref(false)
const scrolled   = ref(false)

onMounted(async () => {
  await loadTheme()
  window.addEventListener('scroll', onScroll, { passive: true })
  onScroll()
})
function onScroll() { scrolled.value = window.scrollY > 12 }
watch(() => route.fullPath, () => { mobileOpen.value = false })

// ── Theme palette ─────────────────────────────────────────────────────────────
const themeColors = computed(() => {
  const themes = {
    // ── dark ──────────────────────────────────────────────────────────────────
    ocean:    { light: false, bg: 'bg-slate-900',   orb1: 'bg-blue-600/30',    orb2: 'bg-cyan-500/30',   orb3: 'bg-indigo-500/20',  hover: 'hover:text-blue-300',    activeBar: 'bg-blue-400',    btnGrad: 'from-blue-500 to-cyan-400' },
    emerald:  { light: false, bg: 'bg-slate-900',   orb1: 'bg-emerald-600/30', orb2: 'bg-teal-500/30',   orb3: 'bg-green-500/20',   hover: 'hover:text-emerald-300', activeBar: 'bg-emerald-400', btnGrad: 'from-emerald-500 to-teal-400' },
    amethyst: { light: false, bg: 'bg-slate-900',   orb1: 'bg-purple-600/30',  orb2: 'bg-pink-500/30',   orb3: 'bg-fuchsia-500/20', hover: 'hover:text-purple-300',  activeBar: 'bg-purple-400',  btnGrad: 'from-purple-500 to-pink-400' },
    sunset:   { light: false, bg: 'bg-slate-900',   orb1: 'bg-orange-600/30',  orb2: 'bg-red-500/30',    orb3: 'bg-yellow-500/20',  hover: 'hover:text-orange-300',  activeBar: 'bg-orange-400',  btnGrad: 'from-orange-500 to-red-400' },
    midnight: { light: false, bg: 'bg-gray-950',    orb1: 'bg-slate-700/40',   orb2: 'bg-indigo-900/40', orb3: 'bg-blue-900/30',    hover: 'hover:text-indigo-300',  activeBar: 'bg-indigo-400',  btnGrad: 'from-indigo-500 to-blue-400' },
    mourning: { light: false, bg: 'bg-neutral-950', orb1: 'bg-neutral-800/50', orb2: 'bg-stone-700/40',  orb3: 'bg-neutral-900/50', hover: 'hover:text-neutral-200', activeBar: 'bg-neutral-400', btnGrad: 'from-neutral-700 to-stone-600' },
    // ── light ─────────────────────────────────────────────────────────────────
    sky:      { light: true,  bg: 'bg-sky-50',      orb1: 'bg-sky-300/45',     orb2: 'bg-blue-200/40',   orb3: 'bg-cyan-200/35',    hover: 'hover:text-sky-700',     activeBar: 'bg-sky-500',     btnGrad: 'from-sky-500 to-blue-400' },
    blossom:  { light: true,  bg: 'bg-rose-50',     orb1: 'bg-rose-300/45',    orb2: 'bg-pink-200/40',   orb3: 'bg-fuchsia-200/35', hover: 'hover:text-rose-700',    activeBar: 'bg-rose-500',    btnGrad: 'from-rose-500 to-pink-400' },
    meadow:   { light: true,  bg: 'bg-green-50',    orb1: 'bg-emerald-300/45', orb2: 'bg-teal-200/40',   orb3: 'bg-green-200/35',   hover: 'hover:text-emerald-700', activeBar: 'bg-emerald-500', btnGrad: 'from-emerald-500 to-teal-400' },
    cream:    { light: true,  bg: 'bg-amber-50',    orb1: 'bg-amber-300/45',   orb2: 'bg-orange-200/40', orb3: 'bg-yellow-200/35',  hover: 'hover:text-amber-700',   activeBar: 'bg-amber-500',   btnGrad: 'from-amber-500 to-orange-400' },
  }
  return themes[currentTheme.value] || themes.ocean
})

// Expose to all child components via inject('isLight')
const isLight = computed(() => !!themeColors.value.light)
provide('isLight', isLight)

const navLinks = computed(() => {
  const links = [{ to: '/', label: 'หน้าแรก' }]  // หน้าแรกแสดงเสมอ
  if (navVisibility.value.resume)   links.push({ to: '/resume',   label: 'ประวัติ' })
  if (navVisibility.value.projects) links.push({ to: '/projects', label: portfolioBtnText.value || 'คลังสื่อการสอน' })
  if (navVisibility.value.contact)  links.push({ to: '/contact',  label: 'ติดต่อ' })
  return links
})
</script>

<template>
  <div
    :class="['min-h-screen flex flex-col relative overflow-x-hidden', themeColors.bg]"
    :style="isMourning ? { filter: 'grayscale(1)' } : {}"
  >
    <!-- Animated Background Orbs -->
    <div class="fixed inset-0 w-full h-full pointer-events-none z-0">
      <div :class="['absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full blur-[120px] animate-blob', themeColors.orb1]"></div>
      <div :class="['absolute top-[20%] right-[-10%] w-[50%] h-[50%] rounded-full blur-[120px] animate-blob animation-delay-2000', themeColors.orb2]"></div>
      <div :class="['absolute bottom-[-20%] left-[20%] w-[60%] h-[60%] rounded-full blur-[120px] animate-blob animation-delay-4000', themeColors.orb3]"></div>
    </div>

    <!-- Floating Glass Navbar -->
    <header class="fixed top-0 inset-x-0 z-50 transition-all duration-500 px-3 sm:px-6 lg:px-8" :class="scrolled ? 'pt-2' : 'pt-4'">
      <div
        class="mx-auto max-w-6xl rounded-2xl transition-all duration-500"
        :class="[
          isLight ? 'border border-slate-900/10' : 'border border-white/10',
          scrolled
            ? (isLight ? 'bg-white/90 backdrop-blur-xl shadow-lg' : 'bg-slate-900/70 backdrop-blur-xl shadow-[0_8px_30px_rgba(0,0,0,0.3)]')
            : (isLight ? 'bg-white/40 backdrop-blur-md shadow-sm'  : 'bg-white/5  backdrop-blur-md shadow-[0_4px_20px_rgba(0,0,0,0.15)]'),
        ]"
      >
        <div class="px-4 sm:px-6">
          <div class="flex items-center justify-between h-14 sm:h-16">

            <!-- Logo -->
            <RouterLink to="/" class="flex items-center gap-2 group">
              <div class="w-9 h-9 rounded-xl overflow-hidden shadow-lg group-hover:scale-110 transition-transform flex-shrink-0">
                <img v-if="logoUrl" :src="logoUrl" class="w-full h-full object-cover" alt="logo" />
                <div v-else :class="['w-full h-full bg-gradient-to-br flex items-center justify-center', themeColors.btnGrad]">
                  <span class="text-white font-bold text-sm">{{ (siteName || 'K').charAt(0).toUpperCase() }}</span>
                </div>
              </div>
              <span :class="['text-base sm:text-lg font-bold tracking-tight', isLight ? 'text-slate-800' : 'text-white']">{{ siteName }}</span>
            </RouterLink>

            <!-- Desktop nav -->
            <nav class="hidden md:flex items-center gap-1">
              <RouterLink v-for="link in navLinks" :key="link.to" :to="link.to" custom v-slot="{ navigate, isExactActive }">
                <button
                  @click="navigate"
                  :class="[
                    'relative px-4 py-2 text-sm font-medium rounded-xl transition-all',
                    isExactActive
                      ? (isLight ? 'text-slate-900 bg-slate-900/8' : 'text-white bg-white/10')
                      : [isLight ? 'text-slate-600' : 'text-slate-300', themeColors.hover, isLight ? 'hover:bg-slate-900/5' : 'hover:bg-white/5'],
                  ]"
                >
                  {{ link.label }}
                  <span v-if="isExactActive" :class="['absolute left-1/2 -translate-x-1/2 bottom-1 h-0.5 w-6 rounded-full', themeColors.activeBar]"></span>
                </button>
              </RouterLink>
              <RouterLink to="/admin/login" :class="['ml-3 px-4 py-2 text-sm font-semibold rounded-xl text-white bg-gradient-to-r shadow-lg hover:shadow-xl hover:-translate-y-0.5 transition-all', themeColors.btnGrad]">
                ผู้ดูแลระบบ
              </RouterLink>
            </nav>

            <!-- Mobile hamburger -->
            <button
              @click="mobileOpen = !mobileOpen"
              :class="['md:hidden inline-flex items-center justify-center w-10 h-10 rounded-xl transition-colors',
                isLight ? 'text-slate-700 bg-slate-100 hover:bg-slate-200 border border-slate-200' : 'text-slate-200 bg-white/5 hover:bg-white/10 border border-white/10']"
              :aria-expanded="mobileOpen" aria-label="เปิดเมนู"
            >
              <svg v-if="!mobileOpen" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/></svg>
              <svg v-else class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
        </div>

        <!-- Mobile menu -->
        <transition name="mobile-menu">
          <nav v-if="mobileOpen" :class="['md:hidden px-4 py-3 space-y-1 border-t', isLight ? 'border-slate-200' : 'border-white/10']">
            <RouterLink v-for="link in navLinks" :key="link.to" :to="link.to" custom v-slot="{ navigate, isExactActive }">
              <button
                @click="navigate"
                :class="[
                  'w-full flex items-center justify-between px-4 py-3 text-sm font-medium rounded-xl transition-colors',
                  isExactActive
                    ? (isLight ? 'text-slate-900 bg-slate-100' : 'text-white bg-white/10')
                    : (isLight ? 'text-slate-600 hover:text-slate-900 hover:bg-slate-100' : 'text-slate-300 hover:text-white hover:bg-white/5'),
                ]"
              >
                <span>{{ link.label }}</span>
                <span v-if="isExactActive" :class="['w-2 h-2 rounded-full', themeColors.activeBar]"></span>
              </button>
            </RouterLink>
            <RouterLink to="/admin/login" :class="['block text-center px-4 py-3 mt-2 text-sm font-semibold rounded-xl text-white bg-gradient-to-r shadow-lg', themeColors.btnGrad]">
              ผู้ดูแลระบบ
            </RouterLink>
          </nav>
        </transition>
      </div>
    </header>

    <!-- Spacer for fixed nav -->
    <div class="h-20 sm:h-24 flex-shrink-0"></div>

    <!-- Main Content -->
    <main :class="['flex-grow relative z-10', isLight ? 'text-slate-800' : 'text-slate-200']">
      <router-view v-slot="{ Component }">
        <transition name="page" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- Footer -->
    <SiteFooter />
  </div>
</template>

<style>
@keyframes blob {
  0%   { transform: translate(0px, 0px) scale(1); }
  33%  { transform: translate(30px, -50px) scale(1.1); }
  66%  { transform: translate(-20px, 20px) scale(0.9); }
  100% { transform: translate(0px, 0px) scale(1); }
}
.animate-blob { animation: blob 7s infinite; }
.animation-delay-2000 { animation-delay: 2s; }
.animation-delay-4000 { animation-delay: 4s; }

.page-enter-active, .page-leave-active { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
.page-enter-from { opacity: 0; transform: translateY(20px) scale(0.98); }
.page-leave-to  { opacity: 0; transform: translateY(-20px) scale(0.98); }

.mobile-menu-enter-active, .mobile-menu-leave-active { transition: all 0.25s ease; overflow: hidden; }
.mobile-menu-enter-from, .mobile-menu-leave-to { opacity: 0; max-height: 0; }
.mobile-menu-enter-to, .mobile-menu-leave-from { opacity: 1; max-height: 500px; }
</style>
