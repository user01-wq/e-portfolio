<script setup>
import { ref, inject } from 'vue'
import { supabase } from '../lib/supabase'

const props = defineProps({
  project: { type: Object, required: true }
})

const isLight = inject('isLight', ref(false))

// ── Likes — persist via localStorage so 1 browser = 1 like ──────────────────
const hasLiked   = ref(!!localStorage.getItem(`liked_${props.project.id}`))
const localLikes = ref(props.project.likes || 0)

async function handleLike() {
  if (hasLiked.value) return
  localLikes.value++
  hasLiked.value = true
  localStorage.setItem(`liked_${props.project.id}`, '1')
  try {
    await supabase.rpc('increment_project_likes', { project_id: props.project.id })
  } catch {
    localLikes.value--
    hasLiked.value = false
    localStorage.removeItem(`liked_${props.project.id}`)
  }
}

// ── Views — once per session ─────────────────────────────────────────────────
const localViews = ref(props.project.views || 0)

async function handleView() {
  if (sessionStorage.getItem(`viewed_${props.project.id}`)) return
  sessionStorage.setItem(`viewed_${props.project.id}`, '1')
  localViews.value++
  try {
    await supabase.rpc('increment_project_views', { project_id: props.project.id })
  } catch { /* ignore */ }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
function getYouTubeEmbedUrl(url) {
  if (!url) return ''
  const m = url.match(/^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*)/)
  const id = m && m[2].length === 11 ? m[2] : null
  return id ? `https://www.youtube.com/embed/${id}` : url
}

function getIframeSrc(html) {
  if (!html) return ''
  const div = document.createElement('div')
  div.innerHTML = html
  const iframe = div.querySelector('iframe')
  return iframe ? iframe.src : html
}

// ── Open full HTML code in a new tab (for html type) ────────────────────────
function openHtmlFullscreen() {
  handleView()
  const html = props.project.embed_code
  if (!html) return
  const blob = new Blob([html], { type: 'text/html; charset=utf-8' })
  const url  = URL.createObjectURL(blob)
  const win  = window.open(url, '_blank')
  // revoke after the new window has loaded
  if (win) {
    win.addEventListener('load', () => URL.revokeObjectURL(url), { once: true })
  } else {
    setTimeout(() => URL.revokeObjectURL(url), 5000)
  }
}

const TYPE_LABEL = {
  link: 'ลิงก์', file: 'ไฟล์', youtube: 'YouTube',
  google_slide: 'Slides', canva: 'Canva', embed: 'Embed',
  image: 'รูปภาพ', video: 'วิดีโอ', html: 'HTML/JS',
}
</script>

<template>
  <div
    :class="[
      'group flex flex-col rounded-2xl shadow-[0_4px_24px_rgb(0,0,0,0.10)] hover:shadow-xl border overflow-hidden transition-all duration-300 hover:-translate-y-1',
      isLight
        ? 'bg-white/80 backdrop-blur-xl border-slate-200/70'
        : 'bg-white/10 backdrop-blur-xl border-white/10',
    ]"
  >

    <!-- ── Media area ── -->
    <div
      :class="[
        'relative w-full aspect-video flex-shrink-0 overflow-hidden border-b',
        isLight ? 'bg-slate-100 border-slate-200/60' : 'bg-white/5 border-white/10',
      ]"
    >

      <!-- Cover image (first priority — always shown if set) -->
      <img
        v-if="project.image_url"
        :src="project.image_url" :alt="project.title"
        class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
      />

      <!-- Full HTML/JS — rendered live via srcdoc sandbox -->
      <iframe
        v-else-if="project.media_type === 'html' && project.embed_code"
        :srcdoc="project.embed_code"
        class="w-full h-full"
        frameborder="0"
        sandbox="allow-scripts allow-popups allow-forms allow-modals"
        loading="lazy"
        scrolling="no"
      ></iframe>

      <!-- HTML placeholder (no code yet) -->
      <div
        v-else-if="project.media_type === 'html'"
        :class="[
          'w-full h-full flex flex-col items-center justify-center gap-2',
          isLight ? 'text-slate-400 bg-slate-50' : 'text-slate-400 bg-white/5',
        ]"
      >
        <svg class="h-12 w-12 opacity-40" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"/>
        </svg>
        <span class="text-xs">HTML/JS Code</span>
      </div>

      <!-- YouTube -->
      <iframe
        v-else-if="project.media_type === 'youtube'"
        :src="getYouTubeEmbedUrl(project.link)"
        class="w-full h-full" frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
      ></iframe>

      <!-- Canva / Google Slides / Embed -->
      <iframe
        v-else-if="['canva','google_slide','embed'].includes(project.media_type) && getIframeSrc(project.embed_code)"
        :src="getIframeSrc(project.embed_code)"
        class="w-full h-full" frameborder="0" allowfullscreen
      ></iframe>

      <!-- File placeholder -->
      <div
        v-else-if="project.media_type === 'file'"
        :class="[
          'w-full h-full flex flex-col items-center justify-center transition-colors',
          isLight
            ? 'text-slate-500 bg-slate-50 group-hover:bg-slate-100'
            : 'text-slate-200 bg-white/5 group-hover:bg-white/10',
        ]"
      >
        <svg class="h-14 w-14 mb-2 opacity-55" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
        </svg>
        <span class="text-sm font-medium">ไฟล์เอกสาร</span>
      </div>

      <!-- Generic / link placeholder -->
      <div
        v-else
        :class="[
          'w-full h-full flex flex-col items-center justify-center',
          isLight ? 'text-slate-400 bg-slate-50' : 'text-slate-400 bg-white/5',
        ]"
      >
        <svg class="h-12 w-12 mb-2 opacity-40" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/>
        </svg>
        <span class="text-xs">ลิงก์ภายนอก</span>
      </div>

      <!-- Type badge -->
      <span
        :class="[
          'absolute top-2 left-2 px-2 py-0.5 text-xs rounded-lg backdrop-blur-sm font-medium',
          project.media_type === 'html'
            ? 'bg-violet-600/90 text-white'
            : 'bg-black/60 text-white',
        ]"
      >
        {{ TYPE_LABEL[project.media_type] || project.media_type }}
      </span>

      <!-- HTML fullscreen shortcut (hover overlay) -->
      <button
        v-if="project.media_type === 'html' && project.embed_code"
        @click.stop="openHtmlFullscreen"
        class="absolute top-2 right-2 z-10 w-8 h-8 rounded-lg bg-black/50 hover:bg-black/75 backdrop-blur-sm text-white flex items-center justify-center transition-all opacity-0 group-hover:opacity-100"
        title="เปิดแบบเต็มจอในแท็บใหม่"
      >
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
        </svg>
      </button>
    </div>

    <!-- ── Content ── -->
    <div class="p-5 flex flex-col flex-grow">
      <h3
        :class="['text-base font-bold mb-1.5 leading-snug line-clamp-2', isLight ? 'text-slate-800' : 'text-white']"
      >{{ project.title }}</h3>
      <p
        :class="['text-sm flex-grow mb-4 font-light leading-relaxed line-clamp-3', isLight ? 'text-slate-500' : 'text-slate-300']"
      >{{ project.description }}</p>

      <!-- Stats row -->
      <div
        :class="['flex items-center gap-5 mb-4 pt-3 border-t', isLight ? 'border-slate-200' : 'border-white/10']"
      >
        <button
          @click="handleLike"
          :class="['flex items-center gap-1.5 text-sm transition-colors', hasLiked ? 'text-pink-500' : (isLight ? 'text-slate-400 hover:text-pink-400' : 'text-slate-400 hover:text-pink-300')]"
          :title="hasLiked ? 'ถูกใจแล้ว' : 'กดถูกใจ'"
        >
          <svg :class="['h-4 w-4', hasLiked ? 'fill-current' : 'fill-none']" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
          </svg>
          <span>{{ localLikes }}</span>
        </button>

        <div :class="['flex items-center gap-1.5 text-sm', isLight ? 'text-slate-400' : 'text-slate-400']">
          <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
            <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
          </svg>
          <span>{{ localViews }}</span>
        </div>
      </div>

      <!-- Action button -->
      <div class="mt-auto">

        <!-- HTML type: open fullscreen -->
        <button
          v-if="project.media_type === 'html' && project.embed_code"
          @click="openHtmlFullscreen"
          :class="[
            'inline-flex w-full justify-center items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold transition-colors border',
            isLight
              ? 'bg-violet-50 hover:bg-violet-100 text-violet-700 border-violet-200'
              : 'bg-violet-500/15 hover:bg-violet-500/25 text-violet-300 border-violet-400/30',
          ]"
        >
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
          </svg>
          เปิดแบบเต็มหน้าจอ
        </button>

        <!-- File download -->
        <a
          v-else-if="project.media_type === 'file' && project.file_path"
          :href="project.file_path" target="_blank" rel="noopener noreferrer"
          @click="handleView"
          :class="[
            'inline-flex w-full justify-center items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold transition-colors border',
            isLight
              ? 'bg-slate-100 hover:bg-slate-200 text-slate-700 border-slate-200'
              : 'bg-white/10 hover:bg-white/20 text-white border-white/15',
          ]"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>
          เปิดไฟล์ / ดาวน์โหลด
        </a>

        <!-- External link -->
        <a
          v-else-if="project.link"
          :href="project.link" target="_blank" rel="noopener noreferrer"
          @click="handleView"
          :class="[
            'inline-flex w-full justify-center items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold transition-colors border',
            isLight
              ? 'bg-slate-50 hover:bg-slate-100 text-slate-600 border-slate-200'
              : 'bg-white/5 hover:bg-white/15 text-white border-white/10',
          ]"
        >
          <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
          เปิดในแท็บใหม่
        </a>

        <!-- Embed — no external link -->
        <div
          v-else-if="project.embed_code"
          :class="[
            'text-center text-xs py-2.5 rounded-xl border',
            isLight ? 'text-slate-400 bg-slate-50 border-slate-200' : 'text-slate-400 bg-white/5 border-white/8',
          ]"
        >
          สื่อฝังในเว็บ (Embed)
        </div>
      </div>
    </div>
  </div>
</template>
