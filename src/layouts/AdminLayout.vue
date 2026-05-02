<script setup>
import { ref, provide, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

const router = useRouter()
const sidebarOpen = ref(false)
const activeTab   = ref('profile')
const unreadCount = ref(0)

// ── Provide tab state + unread refresh to Dashboard.vue ──────────────────────
provide('adminTab', activeTab)
provide('setAdminTab', (tab) => { activeTab.value = tab; sidebarOpen.value = false })
provide('refreshUnread', loadUnread)

async function loadUnread() {
  const { count } = await supabase
    .from('contact_messages')
    .select('*', { count: 'exact', head: true })
    .eq('is_read', false)
  unreadCount.value = count || 0
}

onMounted(loadUnread)

const handleLogout = async () => {
  await supabase.auth.signOut()
  router.push('/admin/login')
}

const NAV_TABS = [
  {
    key: 'profile', label: 'ข้อมูลส่วนตัว',
    icon: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z',
  },
  {
    key: 'experiences', label: 'ประสบการณ์ทำงาน',
    icon: 'M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  },
  {
    key: 'educations', label: 'ประวัติการศึกษา',
    icon: 'M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0112 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222',
  },
  {
    key: 'projects', label: 'คลังสื่อการสอน',
    icon: 'M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10',
  },
  {
    key: 'banners', label: 'แบนเนอร์หน้าแรก',
    icon: 'M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z',
  },
  {
    key: 'messages', label: 'ข้อความ',
    icon: 'M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  },
]
</script>

<template>
  <div class="min-h-screen bg-slate-100">

    <!-- ════════════════ FIXED TOP NAVBAR ════════════════ -->
    <header class="fixed top-0 inset-x-0 h-14 z-50 bg-white border-b border-slate-200 shadow-sm flex items-center gap-3 px-4">

      <!-- Hamburger (mobile only) -->
      <button
        @click="sidebarOpen = !sidebarOpen"
        class="md:hidden p-2 rounded-lg text-slate-500 hover:bg-slate-100 transition-colors flex-shrink-0"
        aria-label="เปิดเมนู"
      >
        <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path v-if="!sidebarOpen" stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
          <path v-else stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>

      <!-- Logo / title -->
      <div class="flex items-center gap-2 flex-shrink-0">
        <div class="w-7 h-7 rounded-lg bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center shadow-sm">
          <svg class="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
          </svg>
        </div>
        <span class="font-bold text-slate-800 text-sm hidden sm:inline">ระบบจัดการ E-Portfolio</span>
        <span class="font-bold text-slate-800 text-sm sm:hidden">Admin</span>
      </div>

      <!-- Breadcrumb / current section (desktop) -->
      <div class="hidden md:flex items-center gap-1.5 text-sm text-slate-400 ml-1">
        <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/>
        </svg>
        <span class="text-slate-600 font-medium">{{ NAV_TABS.find(t => t.key === activeTab)?.label }}</span>
      </div>

      <!-- Spacer -->
      <div class="flex-1"></div>

      <!-- View website -->
      <a
        href="/" target="_blank"
        class="hidden sm:inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-slate-600 bg-slate-100 hover:bg-slate-200 rounded-lg transition-colors border border-slate-200"
      >
        <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
        </svg>
        ดูเว็บไซต์
      </a>

      <!-- Logout (top-right of navbar) -->
      <button
        @click="handleLogout"
        class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-white bg-red-500 hover:bg-red-600 rounded-lg transition-colors shadow-sm"
      >
        <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
        </svg>
        <span class="hidden sm:inline">ออกจากระบบ</span>
      </button>
    </header>

    <!-- ════════════════ MOBILE OVERLAY ════════════════ -->
    <transition name="fade">
      <div
        v-if="sidebarOpen"
        @click="sidebarOpen = false"
        class="fixed inset-0 z-40 bg-black/50 md:hidden"
      ></div>
    </transition>

    <!-- ════════════════ FIXED SIDEBAR ════════════════ -->
    <aside
      :class="[
        'fixed left-0 h-full w-60 z-40 bg-slate-900 text-white flex flex-col transition-transform duration-300 ease-in-out',
        // On desktop: always visible, starts below top navbar
        'md:top-14 md:h-[calc(100vh-3.5rem)] md:translate-x-0',
        // On mobile: full height, slide in/out
        'top-0',
        sidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0',
      ]"
    >
      <!-- Mobile sidebar header (close button + logout) -->
      <div class="md:hidden flex items-center justify-between px-4 h-14 border-b border-slate-800 flex-shrink-0">
        <span class="text-sm font-bold">เมนู</span>
        <button @click="sidebarOpen = false" class="p-1.5 rounded-lg hover:bg-slate-800 text-slate-400 transition-colors">
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>

      <!-- ── Logout (TOP of sidebar = top-left) ── -->
      <div class="px-3 pt-4 pb-2 flex-shrink-0">
        <button
          @click="handleLogout"
          class="w-full flex items-center gap-2.5 px-3 py-2.5 text-sm font-semibold rounded-xl bg-red-500/15 text-red-300 hover:bg-red-500 hover:text-white border border-red-500/25 hover:border-red-500 transition-all duration-200"
        >
          <svg class="w-4 h-4 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
          </svg>
          ออกจากระบบ
        </button>
      </div>

      <!-- ── Nav items ── -->
      <nav class="flex-grow py-2 overflow-y-auto space-y-0.5 px-3">
        <p class="px-2 py-1 text-[10px] font-semibold uppercase tracking-widest text-slate-500 mb-1">จัดการข้อมูล</p>

        <button
          v-for="tab in NAV_TABS" :key="tab.key"
          @click="activeTab = tab.key; sidebarOpen = false"
          :class="[
            'w-full flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-xl transition-all duration-150 text-left',
            activeTab === tab.key
              ? 'bg-blue-600 text-white shadow-sm'
              : 'text-slate-400 hover:bg-slate-800 hover:text-white',
          ]"
        >
          <svg class="w-4 h-4 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">
            <path stroke-linecap="round" stroke-linejoin="round" :d="tab.icon"/>
          </svg>
          <span class="flex-1">{{ tab.label }}</span>
          <span
            v-if="tab.key === 'messages' && unreadCount > 0"
            class="ml-auto inline-flex items-center justify-center min-w-[1.25rem] h-5 px-1.5 rounded-full text-[10px] font-bold bg-red-500 text-white"
          >{{ unreadCount > 99 ? '99+' : unreadCount }}</span>
        </button>
      </nav>

      <!-- ── Bottom: view website ── -->
      <div class="border-t border-slate-800 p-3 flex-shrink-0">
        <a
          href="/" target="_blank"
          class="flex items-center gap-2.5 px-3 py-2.5 text-sm text-slate-400 hover:text-white hover:bg-slate-800 rounded-xl transition-colors"
        >
          <svg class="w-4 h-4 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
          </svg>
          ดูหน้าเว็บไซต์
          <svg class="w-3 h-3 ml-auto opacity-50" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
          </svg>
        </a>
      </div>
    </aside>

    <!-- ════════════════ MAIN CONTENT ════════════════ -->
    <main class="pt-14 md:pl-60 min-h-screen">
      <router-view />
    </main>

  </div>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
