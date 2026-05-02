<script setup>
import { ref, computed, watch, onMounted, inject } from 'vue'
import { supabase } from '../lib/supabase'
import ProjectCard from '../components/ProjectCard.vue'

const isLight = inject('isLight', ref(false))

// ── State ────────────────────────────────────────────────────────────────────
const loading  = ref(true)
const projects = ref([])
const profile  = ref({ portfolio_title: '', portfolio_subtitle: '', portfolio_btn_text: 'คลังสื่อการสอน' })

// ── Search / Filter / Pagination ─────────────────────────────────────────────
const searchQuery  = ref('')
const filterType   = ref('all')
const perPage      = ref(12)
const currentPage  = ref(1)

const PER_PAGE_OPTIONS = [
  { value: 6,  label: '6' },
  { value: 12, label: '12' },
  { value: 24, label: '24' },
  { value: -1, label: 'ทั้งหมด' },
]

const TYPE_LABEL = {
  all: 'ทั้งหมด', link: 'ลิงก์เว็บ', file: 'ไฟล์/PDF',
  youtube: 'YouTube', google_slide: 'Google Slides',
  canva: 'Canva', embed: 'Embed', image: 'รูปภาพ', video: 'วิดีโอ',
  html: 'HTML/JS',
}

// ── Load data ────────────────────────────────────────────────────────────────
onMounted(async () => {
  try {
    const [profileRes, projRes] = await Promise.all([
      supabase.from('profiles').select('portfolio_title, portfolio_subtitle, portfolio_btn_text').limit(1).single(),
      supabase.from('projects').select('*').order('created_at', { ascending: false }),
    ])
    if (profileRes.data) profile.value = { ...profile.value, ...profileRes.data }
    if (projRes.data)    projects.value = projRes.data
  } catch (e) {
    console.error('Error fetching projects:', e.message)
  } finally {
    loading.value = false
  }
})

// ── Computed ─────────────────────────────────────────────────────────────────

const availableTypes = computed(() => {
  const types = [...new Set(projects.value.map(p => p.media_type).filter(Boolean))]
  return types.sort()
})

const filteredProjects = computed(() => {
  let list = projects.value
  const q = searchQuery.value.trim().toLowerCase()
  if (q) {
    list = list.filter(p =>
      (p.title?.toLowerCase().includes(q)) ||
      (p.description?.toLowerCase().includes(q))
    )
  }
  if (filterType.value !== 'all') {
    list = list.filter(p => p.media_type === filterType.value)
  }
  return list
})

const totalPages = computed(() =>
  perPage.value === -1 ? 1 : Math.ceil(filteredProjects.value.length / perPage.value)
)

const paginatedProjects = computed(() => {
  if (perPage.value === -1) return filteredProjects.value
  const start = (currentPage.value - 1) * perPage.value
  return filteredProjects.value.slice(start, start + perPage.value)
})

watch([searchQuery, filterType, perPage], () => { currentPage.value = 1 })

const pageRange = computed(() => {
  const total = totalPages.value
  const cur = currentPage.value
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1)
  const range = []
  const delta = 2
  for (let i = Math.max(2, cur - delta); i <= Math.min(total - 1, cur + delta); i++) range.push(i)
  if (range[0] > 2) range.unshift('...')
  if (range[range.length - 1] < total - 1) range.push('...')
  return [1, ...range, total]
})

const sectionTitle    = computed(() => profile.value.portfolio_title    || 'คลังสื่อการสอนและผลงาน')
const sectionSubtitle = computed(() => profile.value.portfolio_subtitle || 'รวบรวมแผนการสอน สื่อการศึกษา และผลงานต่างๆ ที่พัฒนาขึ้นตลอดระยะเวลาการทำงาน')
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10 relative z-10">

    <!-- ── Section Header ── -->
    <div class="text-center max-w-3xl mx-auto mb-10">
      <h1 :class="['text-3xl sm:text-4xl font-extrabold mb-3 drop-shadow-md', isLight ? 'text-slate-800' : 'text-white']">{{ sectionTitle }}</h1>
      <p :class="['text-base sm:text-lg font-light leading-relaxed', isLight ? 'text-slate-500' : 'text-slate-300']">{{ sectionSubtitle }}</p>
    </div>

    <!-- ── Search + Filter Bar ── -->
    <div
      :class="[
        'backdrop-blur-md rounded-2xl border p-4 mb-6 space-y-3',
        isLight ? 'bg-white/70 border-slate-200/80' : 'bg-white/8 border-white/10',
      ]"
    >

      <!-- Row 1: search + perPage -->
      <div class="flex flex-col sm:flex-row gap-3">
        <!-- Search -->
        <div class="relative flex-grow">
          <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
          </svg>
          <input
            v-model="searchQuery"
            type="search"
            placeholder="ค้นหาชื่อหรือคำอธิบาย..."
            :class="[
              'w-full border rounded-xl pl-9 pr-4 py-2.5 text-sm focus:outline-none focus:ring-2 transition',
              isLight
                ? 'bg-white border-slate-200 text-slate-800 placeholder-slate-400 focus:ring-slate-300 focus:border-slate-300'
                : 'bg-white/10 border-white/15 text-white placeholder-slate-400 focus:ring-white/25 focus:border-white/30',
            ]"
          />
        </div>

        <!-- Per page -->
        <div class="flex items-center gap-2 flex-shrink-0">
          <span :class="['text-xs whitespace-nowrap', isLight ? 'text-slate-500' : 'text-slate-400']">แสดง</span>
          <div :class="['flex rounded-xl border overflow-hidden', isLight ? 'border-slate-200' : 'border-white/15']">
            <button
              v-for="opt in PER_PAGE_OPTIONS" :key="opt.value"
              @click="perPage = opt.value"
              :class="[
                'px-3 py-2 text-xs font-medium transition-colors',
                perPage === opt.value
                  ? (isLight ? 'bg-slate-800 text-white' : 'bg-white text-slate-900')
                  : (isLight ? 'text-slate-600 hover:bg-slate-100' : 'text-slate-300 hover:bg-white/10'),
              ]"
            >{{ opt.label }}</button>
          </div>
          <span :class="['text-xs whitespace-nowrap', isLight ? 'text-slate-500' : 'text-slate-400']">รายการ</span>
        </div>
      </div>

      <!-- Row 2: Type filter pills -->
      <div v-if="availableTypes.length > 1" class="flex flex-wrap gap-2">
        <button
          @click="filterType = 'all'"
          :class="[
            'px-3 py-1.5 rounded-full text-xs font-medium transition-colors border',
            filterType === 'all'
              ? (isLight ? 'bg-slate-800 text-white border-transparent' : 'bg-white text-slate-900 border-transparent')
              : (isLight ? 'border-slate-300 text-slate-600 hover:border-slate-400 hover:text-slate-800' : 'border-white/20 text-slate-300 hover:border-white/40 hover:text-white'),
          ]"
        >ทั้งหมด ({{ projects.length }})</button>
        <button
          v-for="type in availableTypes" :key="type"
          @click="filterType = type"
          :class="[
            'px-3 py-1.5 rounded-full text-xs font-medium transition-colors border',
            filterType === type
              ? (isLight ? 'bg-slate-800 text-white border-transparent' : 'bg-white text-slate-900 border-transparent')
              : (isLight ? 'border-slate-300 text-slate-600 hover:border-slate-400 hover:text-slate-800' : 'border-white/20 text-slate-300 hover:border-white/40 hover:text-white'),
          ]"
        >
          {{ TYPE_LABEL[type] || type }} ({{ projects.filter(p => p.media_type === type).length }})
        </button>
      </div>

      <!-- Result count -->
      <div :class="['flex items-center justify-between text-xs', isLight ? 'text-slate-500' : 'text-slate-400']">
        <span>
          <template v-if="searchQuery || filterType !== 'all'">
            พบ <strong :class="isLight ? 'text-slate-800' : 'text-white'">{{ filteredProjects.length }}</strong> จาก {{ projects.length }} รายการ
          </template>
          <template v-else>
            รายการทั้งหมด <strong :class="isLight ? 'text-slate-800' : 'text-white'">{{ projects.length }}</strong> รายการ
          </template>
        </span>
        <span v-if="perPage !== -1 && totalPages > 1">
          หน้า {{ currentPage }} / {{ totalPages }}
        </span>
      </div>
    </div>

    <!-- ── Loading ── -->
    <div v-if="loading" class="flex justify-center py-16">
      <div :class="['animate-spin rounded-full h-12 w-12 border-t-2 border-b-2', isLight ? 'border-slate-600' : 'border-white']"></div>
    </div>

    <!-- ── Empty state ── -->
    <div
      v-else-if="projects.length === 0"
      :class="[
        'text-center py-16 backdrop-blur-md rounded-2xl border',
        isLight ? 'text-slate-500 bg-white/60 border-slate-200' : 'text-slate-400 bg-white/5 border-white/10',
      ]"
    >
      <svg class="h-16 w-16 mx-auto mb-4 opacity-30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
      </svg>
      <p>ยังไม่มีสื่อการสอน</p>
    </div>

    <!-- ── No results (after filter) ── -->
    <div
      v-else-if="filteredProjects.length === 0"
      :class="[
        'text-center py-16 backdrop-blur-md rounded-2xl border',
        isLight ? 'text-slate-500 bg-white/60 border-slate-200' : 'text-slate-400 bg-white/5 border-white/10',
      ]"
    >
      <svg class="h-12 w-12 mx-auto mb-3 opacity-30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
      </svg>
      <p class="mb-2">ไม่พบรายการที่ตรงกับการค้นหา</p>
      <button
        @click="searchQuery = ''; filterType = 'all'"
        :class="['text-sm underline', isLight ? 'text-slate-500 hover:text-slate-700' : 'text-white/60 hover:text-white']"
      >ล้างการค้นหา</button>
    </div>

    <!-- ── Grid ── -->
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <ProjectCard v-for="proj in paginatedProjects" :key="proj.id" :project="proj" />
    </div>

    <!-- ── Pagination ── -->
    <div v-if="!loading && totalPages > 1" class="mt-10 flex items-center justify-center gap-1">
      <button
        @click="currentPage--" :disabled="currentPage === 1"
        :class="[
          'w-9 h-9 rounded-xl border transition-colors flex items-center justify-center disabled:opacity-30 disabled:cursor-not-allowed',
          isLight ? 'border-slate-300 text-slate-700 hover:bg-slate-100' : 'border-white/15 text-white hover:bg-white/10',
        ]"
      >
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/></svg>
      </button>

      <template v-for="p in pageRange" :key="p">
        <span v-if="p === '...'" :class="['px-2 select-none', isLight ? 'text-slate-400' : 'text-slate-500']">…</span>
        <button
          v-else
          @click="currentPage = p"
          :class="[
            'w-9 h-9 rounded-xl text-sm font-medium transition-colors',
            currentPage === p
              ? (isLight ? 'bg-slate-800 text-white' : 'bg-white text-slate-900')
              : (isLight ? 'border border-slate-300 text-slate-700 hover:bg-slate-100' : 'border border-white/15 text-white hover:bg-white/10'),
          ]"
        >{{ p }}</button>
      </template>

      <button
        @click="currentPage++" :disabled="currentPage === totalPages"
        :class="[
          'w-9 h-9 rounded-xl border transition-colors flex items-center justify-center disabled:opacity-30 disabled:cursor-not-allowed',
          isLight ? 'border-slate-300 text-slate-700 hover:bg-slate-100' : 'border-white/15 text-white hover:bg-white/10',
        ]"
      >
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/></svg>
      </button>
    </div>

  </div>
</template>
