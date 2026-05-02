<script setup>
import { ref, onMounted, inject } from 'vue'
import { supabase } from '../lib/supabase'

const isLight = inject('isLight', ref(false))

const loading = ref(true)
const experiences = ref([])
const educations = ref([])

onMounted(async () => {
  try {
    const [expRes, eduRes] = await Promise.all([
      supabase.from('experiences').select('*').eq('is_visible', true).order('sort_order', { ascending: true }),
      supabase.from('educations').select('*').eq('is_visible', true).order('sort_order', { ascending: true })
    ])

    experiences.value = expRes.data || []
    educations.value  = eduRes.data  || []
  } catch (error) {
    console.error('Error fetching resume data:', error.message)
  } finally {
    loading.value = false
  }
})

function formatDate(dateString) {
  if (!dateString) return 'ปัจจุบัน'
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('th-TH', { month: 'short', year: 'numeric' }).format(date)
}
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 relative z-10">

    <h1 :class="['text-4xl font-extrabold mb-16 text-center drop-shadow-md', isLight ? 'text-slate-800' : 'text-white']">
      ประวัติการทำงานและการศึกษา
    </h1>

    <div v-if="loading" class="flex justify-center py-12">
      <div :class="['animate-spin rounded-full h-12 w-12 border-t-2 border-b-2', isLight ? 'border-slate-600' : 'border-white']"></div>
    </div>

    <div v-else class="space-y-16">

      <!-- ── Experience Section ── -->
      <section>
        <div class="flex items-center gap-3 mb-8">
          <div
            :class="[
              'p-3 rounded-xl border shadow-lg',
              isLight
                ? 'bg-slate-100 text-slate-700 border-slate-200'
                : 'bg-white/10 backdrop-blur-md text-white border-white/20',
            ]"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
          </div>
          <h2 :class="['text-3xl font-bold drop-shadow', isLight ? 'text-slate-800' : 'text-white']">ประสบการณ์ทำงาน</h2>
        </div>

        <div
          :class="[
            'space-y-8 relative',
            'before:absolute before:inset-0 before:ml-5 md:before:ml-[2.25rem] before:-translate-x-px before:h-full before:w-0.5 before:bg-gradient-to-b',
            isLight
              ? 'before:from-slate-400/60 before:via-slate-300/30 before:to-transparent'
              : 'before:from-white/50 before:via-white/20 before:to-transparent',
          ]"
        >
          <div
            v-for="exp in experiences" :key="exp.id"
            class="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group is-active"
          >
            <!-- Timeline dot -->
            <div
              :class="[
                'flex items-center justify-center w-10 h-10 rounded-full border-4 shadow shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 z-10',
                isLight
                  ? 'border-white bg-slate-200 text-slate-600'
                  : 'border-slate-900 bg-white/20 backdrop-blur-md text-slate-200',
              ]"
            >
              <div :class="['w-3 h-3 rounded-full', isLight ? 'bg-slate-600' : 'bg-white']"></div>
            </div>

            <!-- Card -->
            <div
              :class="[
                'w-[calc(100%-4rem)] md:w-[calc(50%-2.5rem)] p-6 rounded-2xl border shadow-xl transition-all duration-300 hover:-translate-y-1',
                isLight
                  ? 'bg-white border-slate-200 hover:bg-slate-50'
                  : 'bg-white/10 backdrop-blur-xl border-white/10 hover:bg-white/15',
              ]"
            >
              <div class="flex flex-col md:flex-row md:items-center justify-between mb-2">
                <h3 :class="['font-bold text-xl', isLight ? 'text-slate-800' : 'text-white']">{{ exp.title }}</h3>
                <span
                  :class="[
                    'text-sm font-medium px-3 py-1 rounded-full mt-2 md:mt-0',
                    isLight ? 'text-slate-500 bg-slate-100' : 'text-slate-300 bg-white/5',
                  ]"
                >{{ formatDate(exp.start_date) }} - {{ formatDate(exp.end_date) }}</span>
              </div>
              <h4 :class="['font-medium mb-4', isLight ? 'text-slate-600' : 'text-white/80']">{{ exp.school }}</h4>
              <p :class="['leading-relaxed text-sm font-light', isLight ? 'text-slate-500' : 'text-slate-300']">{{ exp.description }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- ── Education Section ── -->
      <section>
        <div class="flex items-center gap-3 mb-8">
          <div
            :class="[
              'p-3 rounded-xl border shadow-lg',
              isLight
                ? 'bg-slate-100 text-slate-700 border-slate-200'
                : 'bg-white/10 backdrop-blur-md text-white border-white/20',
            ]"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path d="M12 14l9-5-9-5-9 5 9 5z" />
              <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0112 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0112 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222" />
            </svg>
          </div>
          <h2 :class="['text-3xl font-bold drop-shadow', isLight ? 'text-slate-800' : 'text-white']">ประวัติการศึกษา</h2>
        </div>

        <div class="grid gap-6 sm:grid-cols-2">
          <div
            v-for="edu in educations" :key="edu.id"
            :class="[
              'p-6 rounded-2xl border shadow-xl transition-all duration-300 hover:-translate-y-1',
              isLight
                ? 'bg-white border-slate-200 hover:bg-slate-50'
                : 'bg-white/10 backdrop-blur-xl border-white/10 hover:bg-white/15',
            ]"
          >
            <span
              :class="[
                'inline-block px-3 py-1 rounded-full text-xs font-semibold mb-4 border',
                isLight ? 'bg-slate-100 text-slate-600 border-slate-200' : 'bg-white/10 text-white border-white/5',
              ]"
            >{{ edu.year }}</span>
            <h3 :class="['text-xl font-bold mb-2', isLight ? 'text-slate-800' : 'text-white']">{{ edu.degree }}</h3>
            <h4 :class="['font-medium mb-3', isLight ? 'text-slate-600' : 'text-white/80']">{{ edu.school }}</h4>
            <p :class="['text-sm font-light', isLight ? 'text-slate-500' : 'text-slate-300']">{{ edu.description }}</p>
          </div>
        </div>
      </section>

    </div>
  </div>
</template>
