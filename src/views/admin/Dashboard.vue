<script setup>
import { ref, onMounted, inject, computed, watch } from 'vue'
import { supabase } from '../../lib/supabase'
import { Cropper } from 'vue-advanced-cropper'
import 'vue-advanced-cropper/dist/style.css'
import { QuillEditor } from '@vueup/vue-quill'
import '@vueup/vue-quill/dist/vue-quill.snow.css'

const loading = ref(true)
const saving = ref(false)
const profile = ref({
  full_name: '', greeting: 'สวัสดีค่ะ ฉัน', bio: '', avatar_url: '',
  theme: 'ocean', site_name: 'KruPortfolio',
  portfolio_btn_text: 'คลังสื่อการสอน',
  portfolio_title: '', portfolio_subtitle: '',
  show_banners: true, show_profile: true,
  logo_url: '', footer_text: '',
  mourning_mode: false, mourning_end_date: '',
  social_links: {},
  nav_visibility: { resume: true, projects: true, contact: true },
  banner_effect: 'fade',
  solo_banner_id: null,
})

// === Banner Effect Config ===
const BANNER_EFFECTS = [
  { key: 'fade',   label: 'Fade',   icon: '✨' },
  { key: 'slide',  label: 'Slide',  icon: '➡️' },
  { key: 'zoom',   label: 'Zoom',   icon: '🔍' },
  { key: 'flip',   label: 'Flip',   icon: '🔄' },
  { key: 'random', label: 'สุ่ม',    icon: '🎲' },
]

// ── Social Media config ───────────────────────────────────────────────────────
const SOCIAL_PLATFORMS = [
  { key: 'website',   label: 'เว็บไซต์',    color: '#6366f1', placeholder: 'https://yourwebsite.com' },
  { key: 'facebook',  label: 'Facebook',    color: '#1877F2', placeholder: 'https://facebook.com/yourpage' },
  { key: 'youtube',   label: 'YouTube',     color: '#FF0000', placeholder: 'https://youtube.com/@channel' },
  { key: 'tiktok',    label: 'TikTok',      color: '#010101', placeholder: 'https://tiktok.com/@username' },
  { key: 'instagram', label: 'Instagram',   color: '#E1306C', placeholder: 'https://instagram.com/username' },
  { key: 'twitter',   label: 'X (Twitter)', color: '#000000', placeholder: 'https://x.com/username' },
  { key: 'line',      label: 'LINE',        color: '#06C755', placeholder: 'https://line.me/ti/p/~id' },
  { key: 'linkedin',  label: 'LinkedIn',    color: '#0A66C2', placeholder: 'https://linkedin.com/in/username' },
  { key: 'github',    label: 'GitHub',      color: '#24292e', placeholder: 'https://github.com/username' },
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

function normalizeSocialLinks(raw) {
  const out = {}
  SOCIAL_PLATFORMS.forEach(p => {
    out[p.key] = { url: raw?.[p.key]?.url || '', visible: raw?.[p.key]?.visible !== false }
  })
  return out
}
const successMsg = ref('')
// Tab state is controlled by AdminLayout via provide/inject
const activeTab     = inject('adminTab', ref('profile'))
const refreshUnread = inject('refreshUnread', () => {})

// === Messages State ===
const messages       = ref([])
const loadingMsg     = ref(false)
const expandedMsgId  = ref(null)

const unreadMessages = computed(() => messages.value.filter(m => !m.is_read).length)

// === Cropper State (Shared) ===
const cropperRef = ref(null)
const imageToCrop = ref(null)
const showCropModal = ref(false)
const uploadingImage = ref(false)
const cropTarget = ref('avatar') // 'avatar' | 'project_cover'

// === Projects State ===
const projects = ref([])
const showProjectModal = ref(false)
const savingProject = ref(false)
const editingProject = ref({ title: '', description: '', link: '', media_type: 'link', embed_code: '', image_url: '' })
const projectFile = ref(null)

// === Experiences State ===
const experiences = ref([])
const showExpModal = ref(false)
const savingExp = ref(false)
const editingExp = ref({ id: null, title: '', school: '', start_date: '', end_date: '', description: '', is_visible: true })

// === Educations State ===
const educations = ref([])
const showEduModal = ref(false)
const savingEdu = ref(false)
const editingEdu = ref({ id: null, degree: '', school: '', year: '', description: '', is_visible: true })

// === Drag & Drop State ===
const dragExpIdx     = ref(null)
const dragOverExpIdx = ref(null)
const dragEduIdx     = ref(null)
const dragOverEduIdx = ref(null)

// === Banners State ===
const banners = ref([])
const showBannerModal = ref(false)
const savingBanner = ref(false)
const editingBanner = ref({ id: null, media_type: 'image', media_url: '', title: '', caption: '', link_url: '', sort_order: 0, is_pinned: false, is_visible: true, object_position: 'center' })
const bannerFile = ref(null)
const uploadingBanner = ref(false)
const swapMode = ref(false)
const swapSelected = ref(null) // banner id to swap

onMounted(async () => {
  await loadData()
})

watch(activeTab, (tab) => {
  if (tab === 'messages') loadMessages()
})

async function loadData() {
  try {
    loading.value = true
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      // Load Profile
      const { data: profileData } = await supabase.from('profiles').select('*').eq('id', user.id).single()
      if (profileData) {
        profile.value = profileData
        profile.value.social_links  = normalizeSocialLinks(profileData.social_links)
        profile.value.nav_visibility = {
          resume:   profileData.nav_visibility?.resume   ?? true,
          projects: profileData.nav_visibility?.projects ?? true,
          contact:  profileData.nav_visibility?.contact  ?? true,
        }
        profile.value.banner_effect   = profileData.banner_effect   || 'fade'
        profile.value.solo_banner_id  = profileData.solo_banner_id  || null
      } else {
        profile.value.social_links    = normalizeSocialLinks({})
        profile.value.banner_effect   = 'fade'
        profile.value.solo_banner_id  = null
      }

      // Load Projects
      const { data: projectsData } = await supabase.from('projects').select('*').eq('profile_id', user.id).order('created_at', { ascending: false })
      if (projectsData) projects.value = projectsData
      
      // Load Experiences
      const { data: expData } = await supabase.from('experiences').select('*').eq('profile_id', user.id).order('sort_order', { ascending: true })
      if (expData) experiences.value = expData

      // Load Educations
      const { data: eduData } = await supabase.from('educations').select('*').eq('profile_id', user.id).order('sort_order', { ascending: true })
      if (eduData) educations.value = eduData

      // Load Banners
      const { data: bannerData } = await supabase.from('banners').select('*')
        .eq('profile_id', user.id)
        .order('is_pinned', { ascending: false })
        .order('sort_order', { ascending: true })
        .order('created_at', { ascending: false })
      if (bannerData) banners.value = bannerData
    }
  } catch (error) {
    console.error('Error loading data:', error)
  } finally {
    loading.value = false
  }
}

// === Profile Functions ===

async function saveProfile() {
  try {
    saving.value = true
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      await supabase.from('profiles').upsert({
        id: user.id,
        full_name:         profile.value.full_name,
        greeting:          profile.value.greeting,
        bio:               profile.value.bio,
        avatar_url:        profile.value.avatar_url,
        theme:             profile.value.theme,
        site_name:         profile.value.site_name,
        portfolio_btn_text: profile.value.portfolio_btn_text,
        portfolio_title:    profile.value.portfolio_title    || null,
        portfolio_subtitle: profile.value.portfolio_subtitle || null,
        show_banners:      profile.value.show_banners ?? true,
        show_profile:      profile.value.show_profile ?? true,
        logo_url:          profile.value.logo_url || null,
        footer_text:       profile.value.footer_text || null,
        mourning_mode:     profile.value.mourning_mode ?? false,
        mourning_end_date: profile.value.mourning_end_date || null,
        nav_visibility:    {
          resume:   profile.value.nav_visibility?.resume   ?? true,
          projects: profile.value.nav_visibility?.projects ?? true,
          contact:  profile.value.nav_visibility?.contact  ?? true,
        },
        banner_effect:     profile.value.banner_effect   || 'fade',
        solo_banner_id:    profile.value.solo_banner_id  || null,
        social_links:      (() => {
          const out = {}
          Object.entries(profile.value.social_links || {}).forEach(([k, v]) => {
            if (v.url?.trim()) out[k] = { url: v.url.trim(), visible: v.visible !== false }
          })
          return out
        })(),
        updated_at:        new Date().toISOString()
      })
      successMsg.value = 'บันทึกข้อมูลส่วนตัวเรียบร้อยแล้ว!'
      setTimeout(() => successMsg.value = '', 3000)
    }
  } catch (error) {
    alert('Error saving profile: ' + error.message)
  } finally {
    saving.value = false
  }
}

// === Cropper Functions ===

function onAvatarSelect(event) {
  const file = event.target.files[0]
  if (file) {
    if (imageToCrop.value) URL.revokeObjectURL(imageToCrop.value)
    imageToCrop.value = URL.createObjectURL(file)
    cropTarget.value = 'avatar'
    showCropModal.value = true
  }
  event.target.value = ''
}

function onProjectCoverSelect(event) {
  const file = event.target.files[0]
  if (file) {
    if (imageToCrop.value) URL.revokeObjectURL(imageToCrop.value)
    imageToCrop.value = URL.createObjectURL(file)
    cropTarget.value = 'project_cover'
    showCropModal.value = true
  }
  event.target.value = ''
}

function onBannerImageSelect(event) {
  const file = event.target.files[0]
  if (file) {
    if (imageToCrop.value) URL.revokeObjectURL(imageToCrop.value)
    imageToCrop.value = URL.createObjectURL(file)
    cropTarget.value = 'banner'
    showCropModal.value = true
  }
  event.target.value = ''
}

function onLogoSelect(event) {
  const file = event.target.files[0]
  if (file) {
    if (imageToCrop.value) URL.revokeObjectURL(imageToCrop.value)
    imageToCrop.value = URL.createObjectURL(file)
    cropTarget.value = 'logo'
    showCropModal.value = true
  }
  event.target.value = ''
}

// Extract storage path from public URL so we can delete it
function getStoragePath(url) {
  if (!url || typeof url !== 'string') return null
  const marker = '/storage/v1/object/public/portfolio_files/'
  const idx = url.indexOf(marker)
  if (idx < 0) return null
  try { return decodeURIComponent(url.substring(idx + marker.length)) }
  catch { return url.substring(idx + marker.length) }
}

async function deleteStorageFileIfOurs(url) {
  const path = getStoragePath(url)
  if (!path) return
  await supabase.storage.from('portfolio_files').remove([path])
}

// Convert pasted URL or iframe HTML to a clean embed URL with autoplay/loop
function normalizeEmbedUrl(rawInput, type) {
  if (!rawInput) return ''
  let url = rawInput.trim()
  // Extract src if user pasted full <iframe ...>
  const iframeMatch = url.match(/<iframe[^>]*\ssrc=["']([^"']+)["']/i)
  if (iframeMatch) url = iframeMatch[1]
  if (type === 'google_slide') {
    // Convert /pub to /embed for autoplay/loop support
    url = url.replace(/\/pub(\?|$)/, '/embed$1').replace(/\/pub\?/, '/embed?')
    if (!/[?&]start=/.test(url)) url += (url.includes('?') ? '&' : '?') + 'start=true'
    if (!/[?&]loop=/.test(url))  url += '&loop=true'
    if (!/[?&]delayms=/.test(url)) url += '&delayms=4000'
  }
  if (type === 'canva') {
    // Canva embed URLs typically look like https://www.canva.com/design/<id>/view?embed
    if (!/[?&]embed/.test(url)) url += (url.includes('?') ? '&' : '?') + 'embed'
  }
  return url
}

async function uploadCroppedImage() {
  if (!cropperRef.value) return
  uploadingImage.value = true
  const { canvas } = cropperRef.value.getResult()
  
  canvas.toBlob(async (blob) => {
    try {
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        throw new Error('เซสชันหมดอายุ กรุณาออกจากระบบแล้วล็อกอินใหม่')
      }

      let bucket, fileName
      if (cropTarget.value === 'avatar') {
        bucket = 'avatars'
        fileName = `${user.id}-${Date.now()}.jpg`
      } else if (cropTarget.value === 'logo') {
        bucket = 'portfolio_files'
        fileName = `${user.id}/logo/${Date.now()}.jpg`
      } else if (cropTarget.value === 'banner') {
        bucket = 'portfolio_files'
        fileName = `${user.id}/banners/${Date.now()}.jpg`
      } else {
        bucket = 'portfolio_files'
        fileName = `${user.id}-${Date.now()}.jpg`
      }

      const { error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(fileName, blob, { contentType: 'image/jpeg', upsert: true })

      if (uploadError) throw uploadError

      const { data: publicUrlData } = supabase.storage.from(bucket).getPublicUrl(fileName)

      if (cropTarget.value === 'avatar') {
        profile.value.avatar_url = publicUrlData.publicUrl
        await saveProfile()
      } else if (cropTarget.value === 'logo') {
        if (profile.value.logo_url) await deleteStorageFileIfOurs(profile.value.logo_url)
        profile.value.logo_url = publicUrlData.publicUrl
        await saveProfile()
      } else if (cropTarget.value === 'banner') {
        // Delete previous banner file if it was on our storage
        if (editingBanner.value.media_url) await deleteStorageFileIfOurs(editingBanner.value.media_url)
        editingBanner.value.media_url = publicUrlData.publicUrl
        editingBanner.value.media_type = 'image'
      } else {
        editingProject.value.image_url = publicUrlData.publicUrl
      }

      showCropModal.value = false
    } catch (error) {
      alert('Error uploading image: ' + error.message)
    } finally {
      uploadingImage.value = false
    }
  }, 'image/jpeg', 0.85)
}

// === Project Functions ===

function openAddProject() {
  editingProject.value = { title: '', description: '', link: '', media_type: 'link', embed_code: '', image_url: '', id: null, file_path: '' }
  projectFile.value = null
  showProjectModal.value = true
}

function editProject(proj) {
  editingProject.value = { ...proj }
  projectFile.value = null
  showProjectModal.value = true
}

async function deleteProject(id) {
  if (confirm('คุณแน่ใจหรือไม่ว่าต้องการลบผลงานนี้?')) {
    await supabase.from('projects').delete().eq('id', id)
    await loadData()
  }
}

async function saveProject() {
  try {
    savingProject.value = true
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('เซสชันหมดอายุ กรุณาออกจากระบบแล้วล็อกอินใหม่')
    }
    
    let filePath = editingProject.value.file_path
    
    // Upload File if selected
    if (editingProject.value.media_type === 'file' && projectFile.value) {
      const file = projectFile.value
      const dotIdx = file.name.lastIndexOf('.')
      const ext = dotIdx >= 0 ? file.name.slice(dotIdx).toLowerCase().replace(/[^a-z0-9.]/g, '') : ''
      const safeBase = file.name.slice(0, dotIdx >= 0 ? dotIdx : file.name.length)
        .normalize('NFKD')
        .replace(/[^\w-]+/g, '_')
        .replace(/_+/g, '_')
        .replace(/^_|_$/g, '')
        .slice(0, 40) || 'file'
      const fileName = `${user.id}/${Date.now()}_${safeBase}${ext}`
      const { error: uploadError } = await supabase.storage
        .from('portfolio_files')
        .upload(fileName, file, { upsert: true })
        
      if (uploadError) throw uploadError
      const { data: publicUrlData } = supabase.storage.from('portfolio_files').getPublicUrl(fileName)
      
      filePath = publicUrlData.publicUrl
    }

    const payload = {
      profile_id: user.id,
      title: editingProject.value.title,
      description: editingProject.value.description,
      media_type: editingProject.value.media_type,
      link: editingProject.value.link,
      embed_code: editingProject.value.embed_code,
      file_path: filePath,
      image_url: editingProject.value.image_url
    }

    if (editingProject.value.id) {
      await supabase.from('projects').update(payload).eq('id', editingProject.value.id)
    } else {
      await supabase.from('projects').insert(payload)
    }
    
    showProjectModal.value = false
    await loadData()
  } catch (error) {
    alert('Error saving project: ' + error.message)
  } finally {
    savingProject.value = false
  }
}
// === Experiences Functions ===

function openAddExp() {
  editingExp.value = { id: null, title: '', school: '', start_date: '', end_date: '', description: '', is_visible: true }
  showExpModal.value = true
}

async function toggleExpVisible(exp) {
  const next = exp.is_visible === false ? true : false
  exp.is_visible = next
  await supabase.from('experiences').update({ is_visible: next }).eq('id', exp.id)
}

function editExp(exp) {
  editingExp.value = { ...exp }
  showExpModal.value = true
}

async function deleteExp(id) {
  if (confirm('ยืนยันการลบประสบการณ์ทำงานนี้?')) {
    await supabase.from('experiences').delete().eq('id', id)
    await loadData()
  }
}

async function saveExp() {
  try {
    savingExp.value = true
    const { data: { user } } = await supabase.auth.getUser()
    const { id, created_at, ...fields } = editingExp.value
    const payload = {
      ...fields,
      profile_id:  user.id,
      start_date:  fields.start_date || null,
      end_date:    fields.end_date   || null,
      is_visible:  fields.is_visible !== false,
    }

    let err
    if (id) {
      ;({ error: err } = await supabase.from('experiences').update(payload).eq('id', id))
    } else {
      payload.sort_order = experiences.value.length
      ;({ error: err } = await supabase.from('experiences').insert(payload))
    }
    if (err) throw err

    showExpModal.value = false
    await loadData()
  } catch (error) {
    alert('บันทึกไม่สำเร็จ: ' + error.message)
  } finally {
    savingExp.value = false
  }
}

// === Educations Functions ===

function openAddEdu() {
  editingEdu.value = { id: null, degree: '', school: '', year: '', description: '', is_visible: true }
  showEduModal.value = true
}

async function toggleEduVisible(edu) {
  const next = edu.is_visible === false ? true : false
  edu.is_visible = next
  await supabase.from('educations').update({ is_visible: next }).eq('id', edu.id)
}

function editEdu(edu) {
  editingEdu.value = { ...edu }
  showEduModal.value = true
}

async function deleteEdu(id) {
  if (confirm('ยืนยันการลบประวัติการศึกษานี้?')) {
    await supabase.from('educations').delete().eq('id', id)
    await loadData()
  }
}

async function saveEdu() {
  try {
    savingEdu.value = true
    const { data: { user } } = await supabase.auth.getUser()
    const { id, created_at, ...fields } = editingEdu.value
    const payload = {
      ...fields,
      profile_id: user.id,
      is_visible: fields.is_visible !== false,
    }

    let err
    if (id) {
      ;({ error: err } = await supabase.from('educations').update(payload).eq('id', id))
    } else {
      payload.sort_order = educations.value.length
      ;({ error: err } = await supabase.from('educations').insert(payload))
    }
    if (err) throw err

    showEduModal.value = false
    await loadData()
  } catch (error) {
    alert('บันทึกไม่สำเร็จ: ' + error.message)
  } finally {
    savingEdu.value = false
  }
}

// === Date Formatter ===
function formatDate(dateString) {
  if (!dateString) return 'ปัจจุบัน'
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('th-TH', { month: 'short', year: 'numeric' }).format(date)
}

// === Drag & Drop: Experiences ===
function onExpDragStart(e, idx) {
  dragExpIdx.value = idx
  e.dataTransfer.effectAllowed = 'move'
}
function onExpDragOver(e, idx) {
  e.preventDefault()
  e.dataTransfer.dropEffect = 'move'
  dragOverExpIdx.value = idx
}
async function onExpDrop(e, idx) {
  e.preventDefault()
  if (dragExpIdx.value === null || dragExpIdx.value === idx) {
    dragExpIdx.value = null
    dragOverExpIdx.value = null
    return
  }
  const list = [...experiences.value]
  const [moved] = list.splice(dragExpIdx.value, 1)
  list.splice(idx, 0, moved)
  experiences.value = list
  dragExpIdx.value = null
  dragOverExpIdx.value = null
  await saveExpOrder()
}
function onExpDragEnd() {
  dragExpIdx.value = null
  dragOverExpIdx.value = null
}
async function saveExpOrder() {
  await Promise.all(
    experiences.value.map((exp, idx) =>
      supabase.from('experiences').update({ sort_order: idx }).eq('id', exp.id)
    )
  )
}

// === Drag & Drop: Educations ===
function onEduDragStart(e, idx) {
  dragEduIdx.value = idx
  e.dataTransfer.effectAllowed = 'move'
}
function onEduDragOver(e, idx) {
  e.preventDefault()
  e.dataTransfer.dropEffect = 'move'
  dragOverEduIdx.value = idx
}
async function onEduDrop(e, idx) {
  e.preventDefault()
  if (dragEduIdx.value === null || dragEduIdx.value === idx) {
    dragEduIdx.value = null
    dragOverEduIdx.value = null
    return
  }
  const list = [...educations.value]
  const [moved] = list.splice(dragEduIdx.value, 1)
  list.splice(idx, 0, moved)
  educations.value = list
  dragEduIdx.value = null
  dragOverEduIdx.value = null
  await saveEduOrder()
}
function onEduDragEnd() {
  dragEduIdx.value = null
  dragOverEduIdx.value = null
}
async function saveEduOrder() {
  await Promise.all(
    educations.value.map((edu, idx) =>
      supabase.from('educations').update({ sort_order: idx }).eq('id', edu.id)
    )
  )
}

// === Messages Functions ===
async function loadMessages() {
  loadingMsg.value = true
  const { data } = await supabase
    .from('contact_messages')
    .select('*')
    .order('created_at', { ascending: false })
  messages.value = data || []
  loadingMsg.value = false
}

async function markRead(msg) {
  if (msg.is_read) return
  msg.is_read = true
  await supabase.from('contact_messages').update({ is_read: true }).eq('id', msg.id)
  refreshUnread()
}

async function deleteMessage(id) {
  if (!confirm('ยืนยันการลบข้อความนี้?')) return
  messages.value = messages.value.filter(m => m.id !== id)
  await supabase.from('contact_messages').delete().eq('id', id)
  refreshUnread()
}

async function markAllRead() {
  const unread = messages.value.filter(m => !m.is_read)
  unread.forEach(m => m.is_read = true)
  await supabase.from('contact_messages').update({ is_read: true }).eq('is_read', false)
  refreshUnread()
}

function toggleExpand(id) {
  expandedMsgId.value = expandedMsgId.value === id ? null : id
}

function formatMsgDate(d) {
  return new Intl.DateTimeFormat('th-TH', {
    day: 'numeric', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  }).format(new Date(d))
}

// === Banner Functions ===

function openAddBanner() {
  editingBanner.value = { id: null, media_type: 'image', media_url: '', title: '', caption: '', link_url: '', sort_order: banners.value.length, is_pinned: false, is_visible: true, object_position: 'center' }
  bannerFile.value = null
  showBannerModal.value = true
}

async function toggleBannerVisible(b) {
  await supabase.from('banners').update({ is_visible: !b.is_visible }).eq('id', b.id)
  await loadData()
}

// Toggle show/hide profile card on homepage
const togglingShowProfile = ref(false)
async function toggleShowProfile() {
  if (togglingShowProfile.value) return
  try {
    togglingShowProfile.value = true
    const newVal = !(profile.value.show_profile ?? true)
    profile.value.show_profile = newVal
    const { data: { user } } = await supabase.auth.getUser()
    if (user) await supabase.from('profiles').update({ show_profile: newVal }).eq('id', user.id)
  } catch (e) {
    console.error('toggleShowProfile error:', e)
  } finally {
    togglingShowProfile.value = false
  }
}

// Toggle global banner visibility on the homepage (stored in profile)
const togglingShowBanners = ref(false)
async function toggleShowBanners() {
  if (togglingShowBanners.value) return
  try {
    togglingShowBanners.value = true
    const newVal = !(profile.value.show_banners ?? true)
    profile.value.show_banners = newVal
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      await supabase.from('profiles').update({ show_banners: newVal }).eq('id', user.id)
    }
  } catch (e) {
    console.error('toggleShowBanners error:', e)
  } finally {
    togglingShowBanners.value = false
  }
}

async function togglePin(b) {
  await supabase.from('banners').update({ is_pinned: !b.is_pinned }).eq('id', b.id)
  await loadData()
}

function toggleSwapMode() {
  swapMode.value = !swapMode.value
  swapSelected.value = null
}

async function onSwapPick(b) {
  if (!swapMode.value) return
  if (!swapSelected.value) {
    swapSelected.value = b.id
    return
  }
  if (swapSelected.value === b.id) {
    swapSelected.value = null
    return
  }
  const a = banners.value.find(x => x.id === swapSelected.value)
  if (!a) { swapSelected.value = null; return }
  // Swap sort_order between the two
  await supabase.from('banners').update({ sort_order: b.sort_order }).eq('id', a.id)
  await supabase.from('banners').update({ sort_order: a.sort_order }).eq('id', b.id)
  swapSelected.value = null
  swapMode.value = false
  await loadData()
}

function editBanner(b) {
  editingBanner.value = { ...b }
  bannerFile.value = null
  showBannerModal.value = true
}

async function deleteBanner(id) {
  if (!confirm('ยืนยันการลบแบนเนอร์นี้? (ไฟล์จะถูกลบจาก storage ด้วย)')) return
  const target = banners.value.find(b => b.id === id)
  if (target) await deleteStorageFileIfOurs(target.media_url)
  await supabase.from('banners').delete().eq('id', id)
  await loadData()
}

function onBannerFileSelect(e) {
  const file = e.target.files[0]
  if (!file) return
  bannerFile.value = file
  if (file.type.startsWith('video/')) editingBanner.value.media_type = 'video'
  else if (file.type.startsWith('image/')) editingBanner.value.media_type = 'image'
}

async function moveBanner(b, dir) {
  const list = [...banners.value]
  const idx = list.findIndex(x => x.id === b.id)
  const swap = idx + dir
  if (swap < 0 || swap >= list.length) return
  const a = list[idx], c = list[swap]
  await supabase.from('banners').update({ sort_order: c.sort_order }).eq('id', a.id)
  await supabase.from('banners').update({ sort_order: a.sort_order }).eq('id', c.id)
  await loadData()
}

// Set banner slideshow transition effect
async function setBannerEffect(eff) {
  profile.value.banner_effect = eff
  const { data: { user } } = await supabase.auth.getUser()
  if (user) await supabase.from('profiles').update({ banner_effect: eff }).eq('id', user.id)
}

// Toggle Solo Mode — show only this banner on the homepage; call again to clear
async function setSoloBanner(id) {
  const newId = profile.value.solo_banner_id === id ? null : id
  profile.value.solo_banner_id = newId
  const { data: { user } } = await supabase.auth.getUser()
  if (user) await supabase.from('profiles').update({ solo_banner_id: newId }).eq('id', user.id)
}

async function saveBanner() {
  try {
    savingBanner.value = true
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) throw new Error('เซสชันหมดอายุ กรุณาออกจากระบบแล้วล็อกอินใหม่')

    let mediaUrl = editingBanner.value.media_url
    const type = editingBanner.value.media_type
    const isEmbed = type === 'google_slide' || type === 'canva'

    if (bannerFile.value) {
      uploadingBanner.value = true
      const file = bannerFile.value
      const dotIdx = file.name.lastIndexOf('.')
      const ext = dotIdx >= 0 ? file.name.slice(dotIdx).toLowerCase().replace(/[^a-z0-9.]/g, '') : ''
      const safeBase = file.name.slice(0, dotIdx >= 0 ? dotIdx : file.name.length)
        .normalize('NFKD')
        .replace(/[^\w-]+/g, '_')
        .replace(/_+/g, '_')
        .replace(/^_|_$/g, '')
        .slice(0, 40) || 'banner'
      const fileName = `${user.id}/banners/${Date.now()}_${safeBase}${ext}`
      const { error: upErr } = await supabase.storage
        .from('portfolio_files')
        .upload(fileName, file, { upsert: true, contentType: file.type })
      if (upErr) throw upErr
      // Delete old file if we are replacing it (only if it was on our storage and is different)
      const oldUrl = editingBanner.value.id
        ? (banners.value.find(b => b.id === editingBanner.value.id)?.media_url)
        : null
      if (oldUrl && oldUrl !== mediaUrl) await deleteStorageFileIfOurs(oldUrl)
      mediaUrl = supabase.storage.from('portfolio_files').getPublicUrl(fileName).data.publicUrl
      uploadingBanner.value = false
    } else if (isEmbed) {
      mediaUrl = normalizeEmbedUrl(mediaUrl, type)
    }

    if (!mediaUrl) throw new Error('กรุณาเลือกไฟล์ หรือใส่ URL')

    const payload = {
      profile_id: user.id,
      media_type: type,
      media_url: mediaUrl,
      title: editingBanner.value.title || null,
      caption: editingBanner.value.caption || null,
      link_url: editingBanner.value.link_url || null,
      sort_order: editingBanner.value.sort_order ?? 0,
      is_pinned: !!editingBanner.value.is_pinned,
      is_visible: editingBanner.value.is_visible !== false,
      object_position: editingBanner.value.object_position || 'center',
    }

    if (editingBanner.value.id) {
      await supabase.from('banners').update(payload).eq('id', editingBanner.value.id)
    } else {
      await supabase.from('banners').insert(payload)
    }

    showBannerModal.value = false
    await loadData()
  } catch (error) {
    alert('Error saving banner: ' + error.message)
  } finally {
    savingBanner.value = false
    uploadingBanner.value = false
  }
}
</script>

<template>
  <div class="p-5 md:p-8 max-w-5xl mx-auto space-y-6">

    <div v-if="loading" class="flex justify-center py-16">
      <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-600"></div>
    </div>

    <template v-else>

      <!-- Profile Tab -->
      <div v-if="activeTab === 'profile'" class="bg-white shadow rounded-lg border border-slate-200 p-6">
        <h2 class="text-lg font-medium text-slate-900 mb-6 border-b border-slate-100 pb-2">ข้อมูลส่วนตัว และ รูปโปรไฟล์</h2>
        
        <div class="flex flex-col md:flex-row gap-8">
          <div class="flex flex-col items-center gap-4">
            <img :src="profile.avatar_url || 'https://via.placeholder.com/150'" class="w-32 h-32 rounded-full object-cover border-4 border-slate-100 shadow-md" />
            <label class="cursor-pointer inline-flex justify-center py-2 px-4 border border-slate-300 shadow-sm text-sm font-medium rounded-md text-slate-700 bg-white hover:bg-slate-50 transition-colors">
              เปลี่ยนรูปโปรไฟล์
              <input type="file" class="hidden" accept="image/*" @change="onAvatarSelect" />
            </label>
          </div>

          <form @submit.prevent="saveProfile" class="flex-grow space-y-4">
            <div>
              <label class="block text-sm font-medium text-slate-700">ชื่อ-นามสกุล</label>
              <input type="text" v-model="profile.full_name" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700">คำทักทายหน้าแรก (Greeting)</label>
              <input type="text" v-model="profile.greeting" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="เช่น สวัสดีค่ะ ฉัน, Hello I am">
            </div>
            <!-- Site Settings -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 border-t border-slate-100 pt-4 mt-2">
              <div>
                <label class="block text-sm font-medium text-slate-700">ชื่อเว็บไซต์ (Logo text)</label>
                <input type="text" v-model="profile.site_name" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="KruPortfolio">
              </div>
              <div>
                <label class="block text-sm font-medium text-slate-700">ชื่อปุ่ม/เมนู คลังสื่อ</label>
                <input type="text" v-model="profile.portfolio_btn_text" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="คลังสื่อการสอน">
                <p class="text-xs text-slate-400 mt-1">แสดงในเมนูบนสุดและปุ่มหน้าแรก (เช่น ผลงาน/รางวัล)</p>
              </div>
            </div>
            <!-- Portfolio section title + subtitle -->
            <div class="grid grid-cols-1 gap-4 border border-blue-100 bg-blue-50/60 rounded-lg p-4 mt-1">
              <div class="flex items-center gap-2 mb-1">
                <span class="text-sm font-semibold text-blue-800">🗂️ ปรับชื่อส่วนคลังสื่อ (ยืดหยุ่นได้)</span>
                <span class="text-xs text-blue-500">ปล่อยว่างเพื่อใช้ค่าเริ่มต้น</span>
              </div>
              <div>
                <label class="block text-sm font-medium text-slate-700">หัวข้อหน้าคลังสื่อ (H1)</label>
                <input type="text" v-model="profile.portfolio_title" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="คลังสื่อการสอนและผลงาน / ผลงาน/รางวัล / ..." />
              </div>
              <div>
                <label class="block text-sm font-medium text-slate-700">คำอธิบายใต้หัวข้อ (Subtitle)</label>
                <textarea rows="2" v-model="profile.portfolio_subtitle" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="รวบรวมแผนการสอน สื่อการศึกษา และผลงานต่างๆ ..."></textarea>
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">ประวัติย่อ (Bio)</label>
              <div class="border border-slate-300 rounded-md shadow-sm bg-white overflow-hidden pb-12">
                <QuillEditor v-model:content="profile.bio" contentType="html" theme="snow" class="min-h-[150px]" />
              </div>
            </div>
            
            <div class="border-t border-slate-100 pt-4 mt-2">
              <label class="block text-sm font-medium text-slate-700 mb-2">เลือกธีมเว็บไซต์หน้าบ้าน (Public Site Theme)</label>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-slate-50 transition-colors" :class="profile.theme === 'ocean' ? 'border-blue-500 bg-blue-50' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="ocean" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-blue-600 to-cyan-500"></div>
                    <span class="text-sm font-medium text-slate-900">Ocean Blue</span>
                  </div>
                </label>
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-slate-50 transition-colors" :class="profile.theme === 'emerald' ? 'border-emerald-500 bg-emerald-50' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="emerald" class="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-emerald-500 to-teal-400"></div>
                    <span class="text-sm font-medium text-slate-900">Emerald Glow</span>
                  </div>
                </label>
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-slate-50 transition-colors" :class="profile.theme === 'amethyst' ? 'border-purple-500 bg-purple-50' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="amethyst" class="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-purple-600 to-pink-500"></div>
                    <span class="text-sm font-medium text-slate-900">Amethyst Purple</span>
                  </div>
                </label>
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-slate-50 transition-colors" :class="profile.theme === 'sunset' ? 'border-orange-500 bg-orange-50' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="sunset" class="h-4 w-4 text-orange-600 focus:ring-orange-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-orange-500 to-red-500"></div>
                    <span class="text-sm font-medium text-slate-900">Sunset Orange</span>
                  </div>
                </label>
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-slate-50 transition-colors" :class="profile.theme === 'midnight' ? 'border-slate-700 bg-slate-100' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="midnight" class="h-4 w-4 text-slate-800 focus:ring-slate-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-slate-800 to-indigo-900"></div>
                    <span class="text-sm font-medium text-slate-900">Midnight Dark</span>
                  </div>
                </label>
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-slate-50 transition-colors" :class="profile.theme === 'mourning' ? 'border-neutral-700 bg-neutral-100' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="mourning" class="h-4 w-4 text-neutral-700 focus:ring-neutral-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-neutral-900 border border-neutral-600"></div>
                    <span class="text-sm font-medium text-slate-900">🖤 Mourning (ไว้ทุกข์)</span>
                  </div>
                </label>
              </div>

              <!-- Light themes -->
              <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide mt-3 mb-1">☀️ ธีมสว่าง (Light)</p>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-sky-50 transition-colors" :class="profile.theme === 'sky' ? 'border-sky-500 bg-sky-50' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="sky" class="h-4 w-4 text-sky-600 focus:ring-sky-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-sky-500 to-blue-400 border border-sky-200"></div>
                    <span class="text-sm font-medium text-slate-900">Sky Blue (สว่าง)</span>
                  </div>
                </label>
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-rose-50 transition-colors" :class="profile.theme === 'blossom' ? 'border-rose-500 bg-rose-50' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="blossom" class="h-4 w-4 text-rose-600 focus:ring-rose-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-rose-500 to-pink-400 border border-rose-200"></div>
                    <span class="text-sm font-medium text-slate-900">Blossom Pink (สว่าง)</span>
                  </div>
                </label>
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-green-50 transition-colors" :class="profile.theme === 'meadow' ? 'border-emerald-500 bg-green-50' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="meadow" class="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-emerald-500 to-teal-400 border border-green-200"></div>
                    <span class="text-sm font-medium text-slate-900">Meadow Green (สว่าง)</span>
                  </div>
                </label>
                <label class="relative flex items-center p-3 border rounded-lg cursor-pointer hover:bg-amber-50 transition-colors" :class="profile.theme === 'cream' ? 'border-amber-500 bg-amber-50' : 'border-slate-200'">
                  <input type="radio" v-model="profile.theme" value="cream" class="h-4 w-4 text-amber-600 focus:ring-amber-500 border-gray-300">
                  <div class="ml-3 flex items-center gap-2">
                    <div class="w-4 h-4 rounded-full bg-gradient-to-r from-amber-500 to-orange-400 border border-amber-200"></div>
                    <span class="text-sm font-medium text-slate-900">Cream Amber (สว่าง)</span>
                  </div>
                </label>
              </div>
            </div>

            <!-- ─── Logo Upload ─── -->
            <div class="border-t border-slate-100 pt-4 mt-2">
              <label class="block text-sm font-medium text-slate-700 mb-2">🖼️ โลโก้เว็บไซต์ (แสดงแทนตัวอักษรใน Navbar)</label>
              <div class="flex items-center gap-4">
                <div class="w-14 h-14 rounded-xl overflow-hidden border-2 border-slate-200 bg-slate-100 flex-shrink-0 flex items-center justify-center">
                  <img v-if="profile.logo_url" :src="profile.logo_url" class="w-full h-full object-cover" alt="logo" />
                  <svg v-else class="w-6 h-6 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                  </svg>
                </div>
                <div class="flex flex-col gap-2">
                  <label class="cursor-pointer inline-flex justify-center py-2 px-3 border border-slate-300 shadow-sm text-sm font-medium rounded-md text-slate-700 bg-white hover:bg-slate-50 transition-colors">
                    {{ profile.logo_url ? '🔄 เปลี่ยนโลโก้' : '📤 อัปโหลดโลโก้' }}
                    <input type="file" class="hidden" accept="image/*" @change="onLogoSelect" />
                  </label>
                  <button v-if="profile.logo_url" type="button" @click="profile.logo_url = ''" class="text-xs text-red-500 hover:text-red-700 text-left">ลบโลโก้ (ใช้ตัวอักษรแทน)</button>
                </div>
              </div>
            </div>

            <!-- ─── Footer Text ─── -->
            <div class="border-t border-slate-100 pt-4 mt-2">
              <label class="block text-sm font-medium text-slate-700 mb-1">📄 ข้อความ Footer</label>
              <input type="text" v-model="profile.footer_text" placeholder="© 2026 ระบบแฟ้มสะสมผลงานครู สงวนลิขสิทธิ์" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
              <p class="text-xs text-slate-400 mt-1">ปล่อยว่างเพื่อใช้ข้อความเริ่มต้น</p>
            </div>

            <!-- ─── Social Media Links ─── -->
            <div class="border-t border-slate-100 pt-4 mt-2">
              <div class="flex items-center gap-2 mb-3">
                <svg class="w-4 h-4 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/>
                </svg>
                <span class="text-sm font-medium text-slate-700">Social Media Links</span>
                <span class="ml-auto text-xs text-slate-400">ใส่ URL แล้วเปิด/ปิดการแสดงผล</span>
              </div>
              <div class="space-y-1.5">
                <div
                  v-for="p in SOCIAL_PLATFORMS" :key="p.key"
                  class="flex items-center gap-2.5 px-3 py-2 rounded-xl hover:bg-slate-50 transition-colors border border-transparent hover:border-slate-100"
                >
                  <!-- Brand icon -->
                  <div class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
                    :style="{ backgroundColor: p.color + '20', color: p.color }">
                    <svg viewBox="0 0 24 24" class="w-4 h-4" fill="currentColor">
                      <path :d="SOCIAL_SVGS[p.key]" />
                    </svg>
                  </div>
                  <!-- Label -->
                  <span class="text-xs font-medium text-slate-600 w-[4.5rem] flex-shrink-0 truncate">{{ p.label }}</span>
                  <!-- URL input -->
                  <input
                    type="url"
                    v-model="profile.social_links[p.key].url"
                    :placeholder="p.placeholder"
                    class="flex-1 min-w-0 border border-slate-200 rounded-lg py-1.5 px-2.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-blue-400 transition placeholder-slate-300"
                  />
                  <!-- Visible toggle -->
                  <button
                    type="button"
                    @click="profile.social_links[p.key].visible = !profile.social_links[p.key].visible"
                    :disabled="!profile.social_links[p.key].url"
                    :title="profile.social_links[p.key].visible ? 'แสดงอยู่ (คลิกเพื่อซ่อน)' : 'ซ่อนอยู่ (คลิกเพื่อแสดง)'"
                    :class="[
                      'relative inline-flex h-5 w-9 flex-shrink-0 items-center rounded-full transition-colors focus:outline-none disabled:opacity-25 disabled:cursor-not-allowed',
                      profile.social_links[p.key].visible && profile.social_links[p.key].url
                        ? 'bg-emerald-500' : 'bg-slate-300'
                    ]"
                  >
                    <span :class="[
                      'inline-block h-3.5 w-3.5 transform rounded-full bg-white shadow transition-transform duration-200',
                      profile.social_links[p.key].visible && profile.social_links[p.key].url
                        ? 'translate-x-[18px]' : 'translate-x-[2px]'
                    ]"></span>
                  </button>
                </div>
              </div>
              <p class="text-xs text-slate-400 mt-2 pl-1">💡 ไอคอน social ที่ใส่ URL และเปิดแสดงจะแสดงบนโปรไฟล์หน้าแรก</p>
            </div>

            <!-- ─── Profile Card Visibility ─── -->
            <div class="border-t border-slate-100 pt-4 mt-2">
              <div :class="['flex items-center justify-between gap-4 p-3.5 rounded-xl border transition-colors', (profile.show_profile ?? true) ? 'bg-emerald-50 border-emerald-200' : 'bg-slate-100 border-slate-300']">
                <div class="flex items-center gap-3">
                  <div :class="['w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0', (profile.show_profile ?? true) ? 'bg-emerald-100' : 'bg-slate-200']">
                    <svg v-if="profile.show_profile ?? true" class="w-5 h-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                    <svg v-else class="w-5 h-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                  </div>
                  <div>
                    <p class="text-sm font-semibold text-slate-800">แสดงการ์ดข้อมูลส่วนตัว</p>
                    <p :class="['text-xs font-medium', (profile.show_profile ?? true) ? 'text-emerald-700' : 'text-slate-500']">
                      {{ (profile.show_profile ?? true) ? '✅ แสดงโปรไฟล์บนหน้าแรก' : '⚠️ ซ่อนโปรไฟล์จากหน้าแรก' }}
                    </p>
                  </div>
                </div>
                <button type="button" @click="toggleShowProfile" :disabled="togglingShowProfile"
                  :class="['relative inline-flex h-7 w-12 flex-shrink-0 items-center rounded-full transition-colors duration-300 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-60', (profile.show_profile ?? true) ? 'bg-emerald-500 focus:ring-emerald-400' : 'bg-slate-300 focus:ring-slate-400']"
                  role="switch" :aria-checked="profile.show_profile ?? true">
                  <span :class="['inline-block h-5 w-5 transform rounded-full bg-white shadow-md transition-transform duration-300', (profile.show_profile ?? true) ? 'translate-x-6' : 'translate-x-1']"></span>
                </button>
              </div>
            </div>

            <!-- ─── Mourning Mode ─── -->
            <div class="border-t border-slate-100 pt-4 mt-2">
              <p class="text-sm font-medium text-slate-700 mb-3">🖤 โหมดไว้ทุกข์ (Mourning Mode)</p>
              <div :class="['rounded-xl border p-4 transition-colors', profile.mourning_mode ? 'bg-neutral-900 border-neutral-700' : 'bg-slate-50 border-slate-200']">
                <div class="flex items-center justify-between gap-4">
                  <div>
                    <p :class="['text-sm font-semibold', profile.mourning_mode ? 'text-white' : 'text-slate-800']">เปิดโหมดไว้ทุกข์</p>
                    <p :class="['text-xs mt-0.5', profile.mourning_mode ? 'text-neutral-300' : 'text-slate-500']">
                      เว็บไซต์จะแสดงในโทนขาว-ดำ (Grayscale) แก่ผู้เข้าชม
                    </p>
                  </div>
                  <button type="button" @click="profile.mourning_mode = !profile.mourning_mode"
                    :class="['relative inline-flex h-7 w-12 flex-shrink-0 items-center rounded-full transition-colors duration-300 focus:outline-none', profile.mourning_mode ? 'bg-neutral-500' : 'bg-slate-300']">
                    <span :class="['inline-block h-5 w-5 transform rounded-full bg-white shadow-md transition-transform duration-300', profile.mourning_mode ? 'translate-x-6' : 'translate-x-1']"></span>
                  </button>
                </div>
                <div v-if="profile.mourning_mode" class="mt-3 pt-3 border-t border-neutral-700">
                  <label :class="['block text-xs font-medium mb-1', profile.mourning_mode ? 'text-neutral-300' : 'text-slate-600']">วันสิ้นสุดการไว้ทุกข์ (ปล่อยว่างเพื่อไม่มีกำหนด)</label>
                  <input type="date" v-model="profile.mourning_end_date"
                    class="block w-full border border-neutral-600 rounded-md py-2 px-3 text-sm bg-neutral-800 text-white focus:ring-neutral-400 focus:border-neutral-400"
                  />
                  <p v-if="profile.mourning_end_date" class="mt-1 text-xs text-neutral-400">
                    ระบบจะกลับสู่ธีมปกติโดยอัตโนมัติหลัง {{ profile.mourning_end_date }}
                  </p>
                </div>
              </div>
              <p class="text-xs text-slate-400 mt-2">💡 แนะนำให้เลือกธีม "🖤 Mourning" ร่วมกับโหมดนี้</p>
            </div>

            <!-- ── Nav Visibility ───────────────────────────────────────── -->
            <div class="rounded-xl border border-slate-200 overflow-hidden">
              <div class="flex items-center gap-2 px-4 py-3 bg-slate-50 border-b border-slate-200">
                <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                </svg>
                <span class="text-sm font-semibold text-slate-700">เมนูนำทาง (Navbar)</span>
                <span class="ml-auto text-xs text-slate-400">หน้าแรกแสดงเสมอ ซ่อนไม่ได้</span>
              </div>
              <div class="divide-y divide-slate-100">

                <!-- Resume -->
                <div class="flex items-center justify-between px-4 py-3.5 hover:bg-slate-50 transition-colors">
                  <div class="flex items-center gap-3">
                    <div :class="['w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0', profile.nav_visibility?.resume !== false ? 'bg-blue-100' : 'bg-slate-100']">
                      <svg :class="['w-4 h-4', profile.nav_visibility?.resume !== false ? 'text-blue-600' : 'text-slate-400']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                      </svg>
                    </div>
                    <div>
                      <p :class="['text-sm font-medium', profile.nav_visibility?.resume !== false ? 'text-slate-800' : 'text-slate-400']">ประวัติ</p>
                      <p class="text-xs text-slate-400">/resume</p>
                    </div>
                  </div>
                  <button
                    type="button"
                    @click="profile.nav_visibility.resume = !profile.nav_visibility?.resume"
                    :class="['relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-1', profile.nav_visibility?.resume !== false ? 'bg-emerald-500 focus:ring-emerald-400' : 'bg-slate-300 focus:ring-slate-400']"
                  >
                    <span :class="['inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform duration-200', profile.nav_visibility?.resume !== false ? 'translate-x-6' : 'translate-x-1']"></span>
                  </button>
                </div>

                <!-- Projects -->
                <div class="flex items-center justify-between px-4 py-3.5 hover:bg-slate-50 transition-colors">
                  <div class="flex items-center gap-3">
                    <div :class="['w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0', profile.nav_visibility?.projects !== false ? 'bg-blue-100' : 'bg-slate-100']">
                      <svg :class="['w-4 h-4', profile.nav_visibility?.projects !== false ? 'text-blue-600' : 'text-slate-400']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                      </svg>
                    </div>
                    <div>
                      <p :class="['text-sm font-medium', profile.nav_visibility?.projects !== false ? 'text-slate-800' : 'text-slate-400']">{{ profile.portfolio_btn_text || 'คลังสื่อการสอน' }}</p>
                      <p class="text-xs text-slate-400">/projects</p>
                    </div>
                  </div>
                  <button
                    type="button"
                    @click="profile.nav_visibility.projects = !profile.nav_visibility?.projects"
                    :class="['relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-1', profile.nav_visibility?.projects !== false ? 'bg-emerald-500 focus:ring-emerald-400' : 'bg-slate-300 focus:ring-slate-400']"
                  >
                    <span :class="['inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform duration-200', profile.nav_visibility?.projects !== false ? 'translate-x-6' : 'translate-x-1']"></span>
                  </button>
                </div>

                <!-- Contact -->
                <div class="flex items-center justify-between px-4 py-3.5 hover:bg-slate-50 transition-colors">
                  <div class="flex items-center gap-3">
                    <div :class="['w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0', profile.nav_visibility?.contact !== false ? 'bg-blue-100' : 'bg-slate-100']">
                      <svg :class="['w-4 h-4', profile.nav_visibility?.contact !== false ? 'text-blue-600' : 'text-slate-400']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                      </svg>
                    </div>
                    <div>
                      <p :class="['text-sm font-medium', profile.nav_visibility?.contact !== false ? 'text-slate-800' : 'text-slate-400']">ติดต่อ</p>
                      <p class="text-xs text-slate-400">/contact</p>
                    </div>
                  </div>
                  <button
                    type="button"
                    @click="profile.nav_visibility.contact = !profile.nav_visibility?.contact"
                    :class="['relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-1', profile.nav_visibility?.contact !== false ? 'bg-emerald-500 focus:ring-emerald-400' : 'bg-slate-300 focus:ring-slate-400']"
                  >
                    <span :class="['inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform duration-200', profile.nav_visibility?.contact !== false ? 'translate-x-6' : 'translate-x-1']"></span>
                  </button>
                </div>

              </div>
            </div>

            <div v-if="successMsg" class="p-3 bg-green-50 text-green-700 rounded-md text-sm">
              {{ successMsg }}
            </div>
            <div class="flex justify-end pt-2">
              <button type="submit" :disabled="saving" class="py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50">
                {{ saving ? 'กำลังบันทึก...' : 'บันทึกข้อมูลส่วนตัว' }}
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Experiences Tab -->
      <div v-if="activeTab === 'experiences'" class="bg-white shadow rounded-lg border border-slate-200 p-6">
        <!-- Header -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-5 pb-4 border-b border-slate-100">
          <div>
            <h2 class="text-lg font-bold text-slate-800">ประสบการณ์ทำงาน</h2>
            <p class="text-xs text-slate-500 mt-0.5">
              {{ experiences.length }} รายการ ·
              <span class="text-emerald-600 font-medium">{{ experiences.filter(e => e.is_visible !== false).length }} แสดงอยู่</span>
              <span v-if="experiences.filter(e => e.is_visible === false).length" class="text-slate-400"> · {{ experiences.filter(e => e.is_visible === false).length }} ซ่อน</span>
              <span class="text-slate-400"> · ⠿ ลากเพื่อเรียงลำดับ</span>
            </p>
          </div>
          <button @click="openAddExp"
            class="inline-flex items-center gap-1.5 py-2 px-4 text-sm font-semibold rounded-xl text-white bg-blue-600 hover:bg-blue-700 shadow-sm transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            เพิ่มประสบการณ์
          </button>
        </div>

        <!-- Empty state -->
        <div v-if="experiences.length === 0" class="text-center py-14 bg-slate-50 rounded-xl border-2 border-dashed border-slate-200">
          <svg class="w-10 h-10 mx-auto mb-3 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
          </svg>
          <p class="text-sm text-slate-500">ยังไม่มีข้อมูลประสบการณ์ทำงาน</p>
          <button @click="openAddExp" class="mt-2 text-sm text-blue-600 hover:underline font-medium">+ เพิ่มรายการแรก</button>
        </div>

        <!-- List -->
        <div v-else class="space-y-3">
          <div
            v-for="(exp, expIdx) in experiences" :key="exp.id"
            draggable="true"
            @dragstart="onExpDragStart($event, expIdx)"
            @dragover="onExpDragOver($event, expIdx)"
            @drop="onExpDrop($event, expIdx)"
            @dragend="onExpDragEnd"
            :class="[
              'rounded-xl border p-4 flex flex-col sm:flex-row sm:items-start gap-4 transition-all duration-200 cursor-default',
              dragOverExpIdx === expIdx && dragExpIdx !== expIdx
                ? 'ring-2 ring-blue-400 border-blue-300 bg-blue-50/50 scale-[1.01]'
                : exp.is_visible !== false
                  ? 'bg-white border-slate-200 hover:border-slate-300'
                  : 'bg-slate-50 border-slate-200 border-dashed opacity-60',
            ]"
          >
            <!-- Drag Handle -->
            <div class="hidden sm:flex items-center self-stretch cursor-grab active:cursor-grabbing flex-shrink-0 text-slate-300 hover:text-slate-500 transition-colors"
                 title="ลากเพื่อเรียงลำดับ">
              <svg class="w-4 h-6" viewBox="0 0 16 24" fill="currentColor">
                <circle cx="5" cy="6"  r="1.5"/>
                <circle cx="11" cy="6"  r="1.5"/>
                <circle cx="5" cy="12" r="1.5"/>
                <circle cx="11" cy="12" r="1.5"/>
                <circle cx="5" cy="18" r="1.5"/>
                <circle cx="11" cy="18" r="1.5"/>
              </svg>
            </div>

            <!-- Visibility toggle -->
            <div class="flex sm:flex-col items-center gap-2 flex-shrink-0">
              <button
                @click="toggleExpVisible(exp)"
                :class="[
                  'relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-1',
                  exp.is_visible !== false ? 'bg-emerald-500 focus:ring-emerald-400' : 'bg-slate-300 focus:ring-slate-400',
                ]"
                :title="exp.is_visible !== false ? 'คลิกเพื่อซ่อน' : 'คลิกเพื่อแสดง'"
              >
                <span :class="['inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform duration-200', exp.is_visible !== false ? 'translate-x-6' : 'translate-x-1']"></span>
              </button>
              <span :class="['text-[10px] font-semibold uppercase tracking-wide', exp.is_visible !== false ? 'text-emerald-600' : 'text-slate-400']">
                {{ exp.is_visible !== false ? 'แสดง' : 'ซ่อน' }}
              </span>
            </div>

            <!-- Content -->
            <div class="flex-grow min-w-0">
              <p class="text-xs font-medium text-blue-500 mb-0.5">{{ formatDate(exp.start_date) }} — {{ formatDate(exp.end_date) }}</p>
              <h3 class="font-bold text-slate-800 leading-snug">{{ exp.title }}</h3>
              <p class="text-sm font-medium text-slate-500 mt-0.5">📍 {{ exp.school }}</p>
              <p v-if="exp.description" class="text-xs text-slate-400 mt-1.5 line-clamp-2 leading-relaxed">{{ exp.description }}</p>
            </div>

            <!-- Actions -->
            <div class="flex sm:flex-col gap-2 flex-shrink-0">
              <button @click="editExp(exp)"
                class="flex-1 sm:flex-none inline-flex items-center justify-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 border border-blue-200 transition-colors">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                แก้ไข
              </button>
              <button @click="deleteExp(exp.id)"
                class="flex-1 sm:flex-none inline-flex items-center justify-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg bg-red-50 text-red-600 hover:bg-red-100 border border-red-200 transition-colors">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                ลบ
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Educations Tab -->
      <div v-if="activeTab === 'educations'" class="bg-white shadow rounded-lg border border-slate-200 p-6">
        <!-- Header -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-5 pb-4 border-b border-slate-100">
          <div>
            <h2 class="text-lg font-bold text-slate-800">ประวัติการศึกษา</h2>
            <p class="text-xs text-slate-500 mt-0.5">
              {{ educations.length }} รายการ ·
              <span class="text-emerald-600 font-medium">{{ educations.filter(e => e.is_visible !== false).length }} แสดงอยู่</span>
              <span v-if="educations.filter(e => e.is_visible === false).length" class="text-slate-400"> · {{ educations.filter(e => e.is_visible === false).length }} ซ่อน</span>
              <span class="text-slate-400"> · ⠿ ลากเพื่อเรียงลำดับ</span>
            </p>
          </div>
          <button @click="openAddEdu"
            class="inline-flex items-center gap-1.5 py-2 px-4 text-sm font-semibold rounded-xl text-white bg-blue-600 hover:bg-blue-700 shadow-sm transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            เพิ่มประวัติการศึกษา
          </button>
        </div>

        <!-- Empty state -->
        <div v-if="educations.length === 0" class="text-center py-14 bg-slate-50 rounded-xl border-2 border-dashed border-slate-200">
          <svg class="w-10 h-10 mx-auto mb-3 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0112 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222"/>
          </svg>
          <p class="text-sm text-slate-500">ยังไม่มีข้อมูลประวัติการศึกษา</p>
          <button @click="openAddEdu" class="mt-2 text-sm text-blue-600 hover:underline font-medium">+ เพิ่มรายการแรก</button>
        </div>

        <!-- Grid list -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-3">
          <div
            v-for="(edu, eduIdx) in educations" :key="edu.id"
            draggable="true"
            @dragstart="onEduDragStart($event, eduIdx)"
            @dragover="onEduDragOver($event, eduIdx)"
            @drop="onEduDrop($event, eduIdx)"
            @dragend="onEduDragEnd"
            :class="[
              'rounded-xl border p-4 flex flex-col gap-3 transition-all duration-200 cursor-default',
              dragOverEduIdx === eduIdx && dragEduIdx !== eduIdx
                ? 'ring-2 ring-blue-400 border-blue-300 bg-blue-50/50 scale-[1.01]'
                : edu.is_visible !== false
                  ? 'bg-white border-slate-200 hover:border-slate-300'
                  : 'bg-slate-50 border-slate-200 border-dashed opacity-60',
            ]"
          >
            <!-- Top row: drag handle + year badge + toggle -->
            <div class="flex items-center justify-between gap-2">
              <div class="flex items-center gap-2">
                <!-- Grip -->
                <div class="cursor-grab active:cursor-grabbing text-slate-300 hover:text-slate-500 transition-colors flex-shrink-0"
                     title="ลากเพื่อเรียงลำดับ">
                  <svg class="w-3.5 h-5" viewBox="0 0 14 20" fill="currentColor">
                    <circle cx="4"  cy="4"  r="1.5"/>
                    <circle cx="10" cy="4"  r="1.5"/>
                    <circle cx="4"  cy="10" r="1.5"/>
                    <circle cx="10" cy="10" r="1.5"/>
                    <circle cx="4"  cy="16" r="1.5"/>
                    <circle cx="10" cy="16" r="1.5"/>
                  </svg>
                </div>
                <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-indigo-50 text-indigo-700 border border-indigo-200">
                  🎓 {{ edu.year || 'ไม่ระบุปี' }}
                </span>
              </div>
              <div class="flex items-center gap-2">
                <span :class="['text-[10px] font-semibold uppercase tracking-wide', edu.is_visible !== false ? 'text-emerald-600' : 'text-slate-400']">
                  {{ edu.is_visible !== false ? 'แสดง' : 'ซ่อน' }}
                </span>
                <button
                  @click="toggleEduVisible(edu)"
                  :class="[
                    'relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-1',
                    edu.is_visible !== false ? 'bg-emerald-500 focus:ring-emerald-400' : 'bg-slate-300 focus:ring-slate-400',
                  ]"
                  :title="edu.is_visible !== false ? 'คลิกเพื่อซ่อน' : 'คลิกเพื่อแสดง'"
                >
                  <span :class="['inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform duration-200', edu.is_visible !== false ? 'translate-x-6' : 'translate-x-1']"></span>
                </button>
              </div>
            </div>

            <!-- Content -->
            <div class="flex-grow">
              <h3 class="font-bold text-slate-800 leading-snug">{{ edu.degree }}</h3>
              <p class="text-sm font-medium text-slate-500 mt-0.5">🏫 {{ edu.school }}</p>
              <p v-if="edu.description" class="text-xs text-slate-400 mt-1.5 line-clamp-2 leading-relaxed">{{ edu.description }}</p>
            </div>

            <!-- Actions -->
            <div class="flex gap-2 pt-2 border-t border-slate-100">
              <button @click="editEdu(edu)"
                class="flex-1 inline-flex items-center justify-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 border border-blue-200 transition-colors">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                แก้ไข
              </button>
              <button @click="deleteEdu(edu.id)"
                class="flex-1 inline-flex items-center justify-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg bg-red-50 text-red-600 hover:bg-red-100 border border-red-200 transition-colors">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                ลบ
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Portfolio / Projects Tab -->
      <div v-if="activeTab === 'projects'" class="bg-white shadow rounded-lg border border-slate-200 p-6">
        <div class="flex justify-between items-center mb-6 border-b border-slate-100 pb-2">
          <h2 class="text-lg font-medium text-slate-900">คลังสื่อการสอนและผลงาน</h2>
          <button @click="openAddProject" class="py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700">
            + เพิ่มผลงานใหม่
          </button>
        </div>
        
        <div v-if="projects.length === 0" class="text-center py-8 text-slate-500">
          ยังไม่มีผลงาน คลิกเพิ่มผลงานใหม่เพื่อเริ่มต้น
        </div>
        
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="proj in projects" :key="proj.id" class="border border-slate-200 rounded-lg p-4 flex flex-col">
            <div class="flex justify-between items-start mb-2">
              <h3 class="font-bold text-slate-900 line-clamp-1" :title="proj.title">{{ proj.title }}</h3>
              <span class="text-xs px-2 py-1 bg-slate-100 text-slate-600 rounded capitalize">{{ proj.media_type }}</span>
            </div>
            <img v-if="proj.image_url" :src="proj.image_url" class="w-full h-32 object-cover rounded mb-3 border border-slate-100" />
            <p class="text-sm text-slate-500 line-clamp-2 mb-4 flex-grow">{{ proj.description }}</p>
            <div class="flex justify-between border-t border-slate-100 pt-3 mt-auto">
              <button @click="editProject(proj)" class="text-sm text-blue-600 hover:text-blue-800">แก้ไข</button>
              <button @click="deleteProject(proj.id)" class="text-sm text-red-600 hover:text-red-800">ลบ</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Banners Tab -->
      <div v-if="activeTab === 'banners'" class="bg-white shadow rounded-lg border border-slate-200 p-6">
        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3 mb-4 border-b border-slate-100 pb-3">
          <div>
            <h2 class="text-lg font-medium text-slate-900">แบนเนอร์สไลด์โชว์หน้าแรก</h2>
            <p class="text-xs text-slate-500 mt-1">รูปภาพเลื่อนทุก 6 วินาที วิดีโอจะเล่นจนจบก่อนเลื่อน</p>
          </div>
          <div class="flex flex-wrap gap-2 items-center">
            <button
              @click="toggleSwapMode"
              :class="['py-2 px-3 border text-sm font-medium rounded-md transition-colors',
                swapMode ? 'border-amber-500 bg-amber-50 text-amber-700' : 'border-slate-300 bg-white text-slate-700 hover:bg-slate-50']"
            >
              {{ swapMode ? 'ยกเลิกการสลับ' : '⇄ สลับตำแหน่ง' }}
            </button>
            <button @click="openAddBanner" class="py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700">
              + เพิ่มแบนเนอร์
            </button>
          </div>
        </div>

        <!-- Global Banner Show/Hide Toggle -->
        <div
          :class="[
            'flex items-center justify-between gap-4 p-3.5 rounded-xl border mb-5 transition-colors duration-300',
            (profile.show_banners ?? true)
              ? 'bg-emerald-50 border-emerald-200'
              : 'bg-slate-100 border-slate-300'
          ]"
        >
          <div class="flex items-center gap-3 min-w-0">
            <div :class="['w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 transition-colors', (profile.show_banners ?? true) ? 'bg-emerald-100' : 'bg-slate-200']">
              <svg v-if="profile.show_banners ?? true" class="w-5 h-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
              </svg>
              <svg v-else class="w-5 h-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.243 4.243L9.88 9.88"/>
              </svg>
            </div>
            <div class="min-w-0">
              <p class="text-sm font-semibold text-slate-800">แสดงสไลด์โชว์บนหน้าแรก</p>
              <p :class="['text-xs font-medium transition-colors', (profile.show_banners ?? true) ? 'text-emerald-700' : 'text-slate-500']">
                {{ (profile.show_banners ?? true) ? '✅ แบนเนอร์กำลังแสดงแก่ผู้เข้าชม' : '⚠️ ซ่อนแบนเนอร์ทั้งหมดออกจากหน้าแรก' }}
              </p>
            </div>
          </div>
          <!-- iOS-style toggle switch -->
          <button
            @click="toggleShowBanners"
            :disabled="togglingShowBanners"
            :class="[
              'relative inline-flex h-7 w-12 flex-shrink-0 items-center rounded-full transition-colors duration-300 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-60 disabled:cursor-not-allowed',
              (profile.show_banners ?? true) ? 'bg-emerald-500 focus:ring-emerald-400' : 'bg-slate-300 focus:ring-slate-400'
            ]"
            :title="(profile.show_banners ?? true) ? 'คลิกเพื่อซ่อนแบนเนอร์' : 'คลิกเพื่อแสดงแบนเนอร์'"
            role="switch"
            :aria-checked="profile.show_banners ?? true"
          >
            <span
              :class="[
                'inline-block h-5 w-5 transform rounded-full bg-white shadow-md transition-transform duration-300',
                (profile.show_banners ?? true) ? 'translate-x-6' : 'translate-x-1'
              ]"
            ></span>
          </button>
        </div>

        <!-- Banner Effect Picker -->
        <div class="mb-5 p-4 bg-slate-50 border border-slate-200 rounded-xl">
          <p class="text-sm font-semibold text-slate-700 mb-1">🎬 เอฟเฟกต์การเปลี่ยนแบนเนอร์</p>
          <p class="text-xs text-slate-500 mb-3">เลือกแอนิเมชันที่ใช้เมื่อแบนเนอร์เปลี่ยนสไลด์</p>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="eff in BANNER_EFFECTS" :key="eff.key"
              @click="setBannerEffect(eff.key)"
              :class="[
                'px-3 py-2 text-sm font-medium rounded-lg border transition-all',
                profile.banner_effect === eff.key
                  ? 'bg-blue-600 text-white border-blue-600 shadow-sm'
                  : 'bg-white text-slate-700 border-slate-300 hover:border-blue-400 hover:bg-blue-50',
              ]"
            >
              {{ eff.icon }} {{ eff.label }}
            </button>
          </div>
        </div>

        <!-- Size guidance -->
        <div class="mb-5 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0 w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
              <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            </div>
            <div class="flex-grow text-sm text-slate-700 space-y-1.5">
              <p class="font-semibold text-blue-900">📏 คำแนะนำขนาดและประเภทสื่อ</p>
              <ul class="space-y-1 list-none">
                <li><span class="font-medium">📐 อัตราส่วน:</span> 16:9 (ระบบมีเครื่องมือครอบให้สำหรับรูป + ตำแหน่งครอบสำหรับวิดีโอ)</li>
                <li><span class="font-medium">🖼️ รูปภาพ:</span> 1920×1080 px ไฟล์ไม่เกิน 2 MB · JPG/WebP</li>
                <li><span class="font-medium">🎬 วิดีโอ MP4:</span> 1280×720 หรือ 1920×1080 · 5–15 วินาที · ไม่เกิน 30 MB · H.264 · ระบบจะรอจนเล่นจบก่อนเลื่อน</li>
                <li><span class="font-medium">📊 Google Slides:</span> ใช้ลิงก์จาก Publish to web · ระบบเล่นอัตโนมัติ + วน loop ทุก 4 วินาที</li>
                <li><span class="font-medium">🎨 Canva:</span> ใช้ลิงก์ Embed (Share → Embed) · เล่นอัตโนมัติเมื่อฝัง</li>
                <li class="text-xs text-slate-500 mt-1">💡 บีบอัดวิดีโอด้วย <a href="https://www.freeconvert.com/video-compressor" target="_blank" class="text-blue-600 hover:underline">FreeConvert</a> หรือ HandBrake ก่อนอัปโหลด</li>
              </ul>
            </div>
          </div>
        </div>

        <!-- Swap mode hint -->
        <div v-if="swapMode" class="mb-4 p-3 bg-amber-50 border border-amber-200 rounded-lg text-sm text-amber-800">
          <strong>โหมดสลับตำแหน่ง:</strong>
          <span v-if="!swapSelected">คลิกแบนเนอร์ตัวแรกที่ต้องการสลับ</span>
          <span v-else class="font-semibold">เลือกแล้ว 1 ตัว — คลิกแบนเนอร์อีกตัวเพื่อสลับตำแหน่ง</span>
        </div>

        <div v-if="banners.length === 0" class="text-center py-12 text-slate-500 border-2 border-dashed border-slate-200 rounded-lg">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto mb-3 text-slate-300" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
          ยังไม่มีแบนเนอร์ คลิก "เพิ่มแบนเนอร์" เพื่อเริ่มต้น
        </div>

        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          <div
            v-for="(b, i) in banners" :key="b.id"
            @click="onSwapPick(b)"
            :class="[
              'rounded-lg overflow-hidden flex flex-col bg-white shadow-sm transition-all border-2',
              b.is_pinned ? 'border-amber-400' : 'border-slate-200',
              !b.is_visible ? 'opacity-60' : '',
              swapMode ? 'cursor-pointer hover:shadow-lg hover:-translate-y-0.5' : '',
              swapMode && swapSelected === b.id ? 'ring-4 ring-amber-300 scale-[0.98]' : '',
            ]"
          >
            <div class="relative w-full aspect-video bg-slate-100 overflow-hidden">
              <img v-if="b.media_type === 'image'" :src="b.media_url" class="w-full h-full object-cover" :style="{ objectPosition: b.object_position || 'center' }" />
              <video v-else-if="b.media_type === 'video'" :src="b.media_url" class="w-full h-full object-cover" :style="{ objectPosition: b.object_position || 'center' }" muted loop autoplay playsinline></video>
              <iframe v-else-if="b.media_type === 'google_slide' || b.media_type === 'canva'" :src="b.media_url" class="w-full h-full pointer-events-none" frameborder="0" allow="autoplay; fullscreen"></iframe>
              <span class="absolute top-2 left-2 text-xs px-2 py-1 bg-black/60 text-white rounded uppercase tracking-wide">
                {{ b.media_type === 'google_slide' ? 'slide' : b.media_type === 'canva' ? 'canva' : b.media_type }}
              </span>
              <span class="absolute top-2 right-2 text-xs px-2 py-1 bg-blue-600 text-white rounded">#{{ i + 1 }}</span>
              <span v-if="b.is_pinned" class="absolute bottom-2 left-2 inline-flex items-center gap-1 text-xs px-2 py-1 bg-amber-400 text-amber-900 rounded font-bold shadow">
                <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path d="M10 2a1 1 0 011 1v1.586l3.707 3.707A1 1 0 0115 9v3a1 1 0 01-1 1h-3v4a1 1 0 11-2 0v-4H6a1 1 0 01-1-1V9a1 1 0 01.293-.707L9 4.586V3a1 1 0 011-1z"/></svg>
                ตรึงไว้
              </span>
              <span v-if="!b.is_visible" class="absolute bottom-2 right-2 inline-flex items-center gap-1 text-xs px-2 py-1 bg-slate-700 text-white rounded font-bold shadow">
                <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z" clip-rule="evenodd"/><path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z"/></svg>
                ซ่อนอยู่
              </span>
            </div>
            <div class="p-4 flex-grow flex flex-col">
              <h3 class="font-semibold text-slate-900 line-clamp-1">{{ b.title || '— ไม่มีหัวข้อ —' }}</h3>
              <p class="text-xs text-slate-500 mt-1 line-clamp-2 flex-grow">{{ b.caption || ' ' }}</p>
              <div class="flex items-center justify-between gap-2 mt-3 pt-3 border-t border-slate-100" @click.stop>
                <div class="flex gap-1">
                  <button @click="moveBanner(b, -1)" :disabled="i === 0 || swapMode" class="p-1.5 rounded hover:bg-slate-100 text-slate-500 disabled:opacity-30 disabled:cursor-not-allowed" title="ย้ายขึ้น">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7" /></svg>
                  </button>
                  <button @click="moveBanner(b, 1)" :disabled="i === banners.length - 1 || swapMode" class="p-1.5 rounded hover:bg-slate-100 text-slate-500 disabled:opacity-30 disabled:cursor-not-allowed" title="ย้ายลง">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
                  </button>
                  <button
                    @click="togglePin(b)"
                    :disabled="swapMode"
                    :class="['p-1.5 rounded transition-colors disabled:opacity-30 disabled:cursor-not-allowed',
                      b.is_pinned ? 'text-amber-600 bg-amber-50 hover:bg-amber-100' : 'text-slate-500 hover:bg-slate-100']"
                    :title="b.is_pinned ? 'ยกเลิกการตรึง' : 'ตรึงไว้บนสุด'"
                  >
                    <svg class="w-4 h-4" :fill="b.is_pinned ? 'currentColor' : 'none'" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h6l5 5v11a2 2 0 01-2 2H7a2 2 0 01-2-2V5z M12 8v8 M9 12h6" /></svg>
                  </button>
                  <button
                    @click="toggleBannerVisible(b)"
                    :disabled="swapMode"
                    :class="['p-1.5 rounded transition-colors disabled:opacity-30 disabled:cursor-not-allowed',
                      b.is_visible ? 'text-emerald-600 bg-emerald-50 hover:bg-emerald-100' : 'text-slate-400 hover:bg-slate-100']"
                    :title="b.is_visible ? 'ซ่อนแบนเนอร์' : 'แสดงแบนเนอร์'"
                  >
                    <svg v-if="b.is_visible" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                    <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.243 4.243L9.88 9.88" /></svg>
                  </button>
                  <!-- Solo Mode button -->
                  <button
                    @click="setSoloBanner(b.id)"
                    :disabled="swapMode"
                    :class="['p-1.5 rounded transition-colors disabled:opacity-30 disabled:cursor-not-allowed',
                      profile.solo_banner_id === b.id
                        ? 'text-purple-600 bg-purple-50 hover:bg-purple-100'
                        : 'text-slate-400 hover:bg-slate-100']"
                    :title="profile.solo_banner_id === b.id ? 'ยกเลิก Solo Mode' : 'Solo — แสดงเฉพาะแบนเนอร์นี้'"
                  >
                    <svg class="w-4 h-4" :fill="profile.solo_banner_id === b.id ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.562.562 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.562.562 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"/>
                    </svg>
                  </button>
                </div>
                <div class="flex gap-2">
                  <button @click="editBanner(b)" :disabled="swapMode" class="text-sm text-blue-600 hover:text-blue-800 disabled:opacity-30 disabled:cursor-not-allowed">แก้ไข</button>
                  <button @click="deleteBanner(b.id)" :disabled="swapMode" class="text-sm text-red-600 hover:text-red-800 disabled:opacity-30 disabled:cursor-not-allowed">ลบ</button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Active Solo Mode banner -->
        <transition name="solo-notice">
          <div
            v-if="profile.solo_banner_id"
            class="mt-4 flex items-center justify-between gap-3 p-3.5 bg-purple-50 border border-purple-200 rounded-xl text-sm"
          >
            <div class="flex items-center gap-2.5 min-w-0">
              <svg class="w-4 h-4 text-purple-500 flex-shrink-0" fill="currentColor" viewBox="0 0 24 24">
                <path d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.562.562 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.562.562 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"/>
              </svg>
              <div class="min-w-0">
                <span class="font-semibold text-purple-800">Solo Mode เปิดอยู่ — </span>
                <span class="text-purple-700">หน้าแรกแสดงเฉพาะ "{{ banners.find(b => b.id === profile.solo_banner_id)?.title || 'ไม่มีหัวข้อ' }}"</span>
              </div>
            </div>
            <button
              @click="setSoloBanner(profile.solo_banner_id)"
              class="flex-shrink-0 text-xs font-semibold px-3 py-1.5 bg-purple-100 hover:bg-purple-200 text-purple-700 hover:text-purple-900 rounded-lg transition-colors"
            >
              ยกเลิก Solo
            </button>
          </div>
        </transition>
      </div>
    </template>

    <!-- Project Modal -->
    <div v-if="showProjectModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
        <div class="p-4 border-b border-slate-200 flex justify-between items-center">
          <h3 class="text-lg font-bold">{{ editingProject.id ? 'แก้ไขผลงาน' : 'เพิ่มผลงานใหม่' }}</h3>
          <button @click="showProjectModal = false" class="text-slate-500 hover:text-slate-700">ปิด</button>
        </div>
        <div class="p-6 overflow-y-auto space-y-4">
          
          <!-- Cover Image Section -->
          <div class="border border-slate-200 rounded-lg p-4 bg-slate-50 flex flex-col items-center">
            <p class="text-sm font-medium text-slate-700 mb-2">ภาพปกผลงาน (Cover Image)</p>
            <div v-if="editingProject.image_url" class="relative mb-3">
              <img :src="editingProject.image_url" class="w-full max-w-sm h-auto rounded border border-slate-200 shadow-sm" />
              <button @click="editingProject.image_url = ''" class="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600 shadow">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
              </button>
            </div>
            <label class="cursor-pointer inline-flex justify-center py-2 px-4 border border-slate-300 shadow-sm text-sm font-medium rounded-md text-slate-700 bg-white hover:bg-slate-50 transition-colors">
              {{ editingProject.image_url ? 'เปลี่ยนภาพปก' : 'อัปโหลดภาพปก' }}
              <input type="file" class="hidden" accept="image/*" @change="onProjectCoverSelect" />
            </label>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700">ชื่อผลงาน</label>
            <input type="text" v-model="editingProject.title" required class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">คำอธิบาย</label>
            <textarea rows="3" v-model="editingProject.description" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-slate-700">ประเภทสื่อ</label>
            <select v-model="editingProject.media_type" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
              <option value="link">ลิงก์เว็บไซต์ทั่วไป (URL)</option>
              <option value="file">อัปโหลดไฟล์ (PDF, เอกสาร)</option>
              <option value="youtube">YouTube Video</option>
              <option value="google_slide">Google Slide (Link)</option>
              <option value="canva">Canva (Link หรือ Embed Code)</option>
              <option value="embed">Embed HTML (โค้ด iframe ทั่วไป)</option>
              <option value="html">🧩 HTML/JS แบบเต็ม (วางโค้ดโดยตรง)</option>
            </select>
          </div>

          <!-- Conditional Fields based on Media Type -->
          <div v-if="editingProject.media_type === 'file'" class="p-4 bg-slate-50 border border-slate-200 rounded-md">
            <label class="block text-sm font-medium text-slate-700 mb-2">เลือกไฟล์จากเครื่อง (เช่น .pdf)</label>
            <input type="file" @change="e => projectFile = e.target.files[0]" class="block w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" />
            <p v-if="editingProject.file_path" class="mt-2 text-xs text-green-600">มีไฟล์ที่อัปโหลดไว้แล้ว (หากเลือกใหม่จะเป็นการแทนที่)</p>
          </div>

          <div v-if="['link', 'youtube', 'google_slide', 'canva'].includes(editingProject.media_type)" class="p-4 bg-slate-50 border border-slate-200 rounded-md">
            <label class="block text-sm font-medium text-slate-700">วางลิงก์ (URL)</label>
            <input type="url" v-model="editingProject.link" placeholder="https://" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>

          <div v-if="['canva', 'embed'].includes(editingProject.media_type)" class="p-4 bg-slate-50 border border-slate-200 rounded-md">
            <label class="block text-sm font-medium text-slate-700">หรือวาง Embed Code (HTML iframe)</label>
            <textarea rows="4" v-model="editingProject.embed_code" placeholder="<iframe src=... ></iframe>" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm font-mono text-xs"></textarea>
          </div>

          <!-- Full HTML/JS Code -->
          <div v-if="editingProject.media_type === 'html'" class="rounded-lg border border-violet-200 bg-violet-50 overflow-hidden">
            <div class="flex items-center gap-2 px-4 py-2.5 bg-violet-100 border-b border-violet-200">
              <svg class="w-4 h-4 text-violet-600 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"/>
              </svg>
              <span class="text-sm font-semibold text-violet-800">วางโค้ด HTML/JS แบบเต็ม</span>
              <span class="ml-auto text-xs text-violet-500">{{ (editingProject.embed_code || '').length.toLocaleString() }} ตัวอักษร</span>
            </div>
            <div class="p-4 space-y-3">
              <p class="text-xs text-violet-700 leading-relaxed">
                วางโค้ดทั้งหมดได้เลย รองรับ <code class="bg-violet-200/60 px-1 rounded">&lt;!DOCTYPE html&gt;</code> เต็มรูปแบบ, CSS inline, JavaScript และ CDN ภายนอก เช่นโค้ดจาก <strong>Canva AI</strong>, CodePen, v0, Bolt ฯลฯ<br/>
                <span class="text-violet-500">⚠️ โค้ดจะรันใน sandbox — ไม่มีสิทธิ์เข้าถึงคุกกี้หรือข้อมูลเว็บ</span>
              </p>
              <textarea
                v-model="editingProject.embed_code"
                rows="14"
                placeholder="<!DOCTYPE html>
<html lang=&quot;th&quot;>
<head>
  <meta charset=&quot;UTF-8&quot;/>
  <title>ผลงาน</title>
  <style>/* CSS ของคุณ */</style>
</head>
<body>
  <!-- เนื้อหา -->
  <script>/* JavaScript ของคุณ */</script>
</body>
</html>"
                class="block w-full border border-violet-300 rounded-md shadow-sm py-2.5 px-3 focus:ring-violet-500 focus:border-violet-500 text-sm font-mono bg-white text-slate-800 leading-relaxed resize-y"
                spellcheck="false"
                autocomplete="off"
                autocorrect="off"
                autocapitalize="off"
              ></textarea>
              <div class="flex items-center gap-2">
                <button
                  v-if="editingProject.embed_code"
                  type="button"
                  @click="() => { const w = window.open('','_blank'); w.document.write(editingProject.embed_code); w.document.close(); }"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium rounded-md text-violet-700 bg-violet-100 hover:bg-violet-200 border border-violet-200 transition-colors"
                >
                  <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
                  ทดสอบโค้ดในแท็บใหม่
                </button>
                <button
                  v-if="editingProject.embed_code"
                  type="button"
                  @click="editingProject.embed_code = ''"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium rounded-md text-red-600 bg-red-50 hover:bg-red-100 border border-red-200 transition-colors"
                >
                  ล้างโค้ด
                </button>
              </div>
            </div>
          </div>
        </div>
        <div class="p-4 border-t border-slate-200 flex justify-end gap-3 bg-slate-50">
          <button @click="showProjectModal = false" class="py-2 px-4 border border-slate-300 rounded-md text-sm font-medium text-slate-700 hover:bg-white">ยกเลิก</button>
          <button @click="saveProject" :disabled="savingProject" class="py-2 px-4 bg-blue-600 rounded-md text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
            {{ savingProject ? 'กำลังบันทึก...' : 'บันทึกข้อมูล' }}
          </button>
        </div>
      </div>
    </div>

    <!-- ══════ Messages Tab ══════ -->
    <div v-if="activeTab === 'messages'" class="bg-white shadow rounded-lg border border-slate-200 p-6">

      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-5 pb-4 border-b border-slate-100">
        <div>
          <h2 class="text-lg font-bold text-slate-800 flex items-center gap-2">
            📨 ข้อความจากผู้เยี่ยมชม
            <span v-if="unreadMessages > 0"
              class="inline-flex items-center justify-center min-w-[1.5rem] h-6 px-1.5 rounded-full text-xs font-bold bg-red-500 text-white">
              {{ unreadMessages }}
            </span>
          </h2>
          <p class="text-xs text-slate-500 mt-0.5">
            {{ messages.length }} ข้อความทั้งหมด ·
            <span class="text-red-500 font-medium">{{ unreadMessages }} ยังไม่อ่าน</span>
          </p>
        </div>
        <div class="flex gap-2">
          <button v-if="unreadMessages > 0" @click="markAllRead"
            class="inline-flex items-center gap-1.5 py-2 px-3 text-xs font-semibold rounded-xl bg-slate-100 text-slate-600 hover:bg-slate-200 border border-slate-200 transition-colors">
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            อ่านทั้งหมด
          </button>
          <button @click="loadMessages"
            class="inline-flex items-center gap-1.5 py-2 px-3 text-xs font-semibold rounded-xl bg-blue-50 text-blue-600 hover:bg-blue-100 border border-blue-200 transition-colors">
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
            รีเฟรช
          </button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loadingMsg" class="flex justify-center py-12">
        <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500"></div>
      </div>

      <!-- Empty -->
      <div v-else-if="messages.length === 0"
        class="text-center py-16 bg-slate-50 rounded-xl border-2 border-dashed border-slate-200">
        <div class="w-14 h-14 rounded-full bg-slate-100 flex items-center justify-center mx-auto mb-3">
          <svg class="w-7 h-7 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
          </svg>
        </div>
        <p class="text-sm text-slate-500">ยังไม่มีข้อความใดๆ</p>
      </div>

      <!-- Message list -->
      <div v-else class="space-y-3">
        <div
          v-for="msg in messages" :key="msg.id"
          :class="[
            'rounded-xl border transition-all duration-200',
            !msg.is_read ? 'border-blue-200 bg-blue-50/40' : 'border-slate-200 bg-white',
          ]"
        >
          <!-- Row header (always visible) -->
          <div
            class="flex items-start gap-3 p-4 cursor-pointer select-none"
            @click="toggleExpand(msg.id); markRead(msg)"
          >
            <!-- Unread dot -->
            <div class="flex-shrink-0 mt-1">
              <span v-if="!msg.is_read" class="block w-2.5 h-2.5 rounded-full bg-blue-500 shadow-sm"></span>
              <span v-else class="block w-2.5 h-2.5 rounded-full bg-slate-200"></span>
            </div>

            <!-- Meta -->
            <div class="flex-grow min-w-0">
              <div class="flex flex-wrap items-center gap-x-2 gap-y-0.5 mb-0.5">
                <span class="font-semibold text-sm text-slate-800">{{ msg.name }}</span>
                <a v-if="msg.email" :href="'mailto:' + msg.email"
                  class="text-xs text-blue-500 hover:underline" @click.stop>
                  {{ msg.email }}
                </a>
                <span v-else class="text-xs text-slate-400 italic">ไม่ได้ระบุอีเมล</span>
              </div>
              <p class="text-xs text-slate-500 leading-relaxed line-clamp-1">
                {{ msg.message }}
              </p>
            </div>

            <!-- Date + chevron -->
            <div class="flex-shrink-0 flex flex-col items-end gap-1">
              <span class="text-[11px] text-slate-400 whitespace-nowrap">{{ formatMsgDate(msg.created_at) }}</span>
              <svg
                :class="['w-4 h-4 text-slate-400 transition-transform duration-200', expandedMsgId === msg.id ? 'rotate-180' : '']"
                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
              </svg>
            </div>
          </div>

          <!-- Expanded content -->
          <div v-if="expandedMsgId === msg.id" class="px-4 pb-4 pt-0">
            <div class="border-t border-slate-100 pt-3">
              <!-- Full message -->
              <p class="text-sm text-slate-700 leading-relaxed whitespace-pre-wrap bg-slate-50 rounded-xl p-4 border border-slate-100">{{ msg.message }}</p>

              <!-- Reply hint -->
              <div v-if="msg.email" class="mt-3 flex items-center gap-2">
                <a :href="`mailto:${msg.email}?subject=ตอบกลับข้อความของคุณ`"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border border-emerald-200 transition-colors">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"/></svg>
                  ตอบกลับทาง Email
                </a>
              </div>
              <p v-else class="mt-2 text-xs text-slate-400 italic">
                ผู้ส่งไม่ได้ระบุอีเมล — ไม่สามารถตอบกลับได้
              </p>

              <!-- Actions -->
              <div class="flex justify-end gap-2 mt-3 pt-3 border-t border-slate-100">
                <button v-if="!msg.is_read" @click="markRead(msg)"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg bg-slate-100 text-slate-600 hover:bg-slate-200 border border-slate-200 transition-colors">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                  ทำเครื่องหมายว่าอ่านแล้ว
                </button>
                <button @click="deleteMessage(msg.id)"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg bg-red-50 text-red-600 hover:bg-red-100 border border-red-200 transition-colors">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                  ลบ
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Crop Modal (Shared for Avatar and Project Cover) -->
    <div v-if="showCropModal" class="fixed inset-0 bg-black/75 z-[60] flex items-center justify-center p-4">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-2xl overflow-hidden flex flex-col">
        <div class="p-4 border-b border-slate-200 flex justify-between items-center">
          <h3 class="text-lg font-bold">{{ cropTarget === 'avatar' ? 'ครอบตัดรูปโปรไฟล์' : 'ครอบตัดรูปภาพปกผลงาน' }}</h3>
          <button @click="showCropModal = false" class="text-slate-500 hover:text-slate-700">ปิด</button>
        </div>
        <div class="bg-slate-900 h-96 w-full flex items-center justify-center">
          <Cropper
            ref="cropperRef"
            class="h-full w-full"
            :src="imageToCrop"
            :stencil-props="{ aspectRatio: (cropTarget === 'avatar' || cropTarget === 'logo') ? 1 : 16/9 }"
          />
        </div>
        <div class="p-4 border-t border-slate-200 flex justify-end gap-3">
          <button @click="showCropModal = false" class="py-2 px-4 border border-slate-300 rounded-md text-sm font-medium text-slate-700 hover:bg-slate-50">ยกเลิก</button>
          <button @click="uploadCroppedImage" :disabled="uploadingImage" class="py-2 px-4 bg-blue-600 rounded-md text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
            {{ uploadingImage ? 'กำลังอัปโหลด...' : 'ยืนยันและอัปโหลด' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Experience Modal -->
    <div v-if="showExpModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
        <div class="p-4 border-b border-slate-200 flex justify-between items-center">
          <h3 class="text-lg font-bold">{{ editingExp.id ? 'แก้ไขประสบการณ์ทำงาน' : 'เพิ่มประสบการณ์ทำงาน' }}</h3>
          <button @click="showExpModal = false" class="text-slate-500 hover:text-slate-700">ปิด</button>
        </div>
        <div class="p-6 overflow-y-auto space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700">ตำแหน่ง / บทบาท</label>
            <input type="text" v-model="editingExp.title" required class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">สถานที่ทำงาน / โรงเรียน</label>
            <input type="text" v-model="editingExp.school" required class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700">วันที่เริ่มต้น (YYYY-MM-DD)</label>
              <input type="date" v-model="editingExp.start_date" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700">วันที่สิ้นสุด (เว้นว่างหากทำถึงปัจจุบัน)</label>
              <input type="date" v-model="editingExp.end_date" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">รายละเอียดงาน (ย่อ)</label>
            <textarea rows="3" v-model="editingExp.description" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
          </div>
          <!-- Visibility toggle -->
          <div :class="['flex items-center justify-between p-3.5 rounded-xl border transition-colors', editingExp.is_visible !== false ? 'bg-emerald-50 border-emerald-200' : 'bg-slate-100 border-slate-300']">
            <div>
              <p class="text-sm font-semibold text-slate-800">การมองเห็น</p>
              <p :class="['text-xs mt-0.5', editingExp.is_visible !== false ? 'text-emerald-700' : 'text-slate-500']">
                {{ editingExp.is_visible !== false ? '✅ แสดงในหน้าประวัติ' : '🙈 ซ่อน ไม่แสดงแก่ผู้เข้าชม' }}
              </p>
            </div>
            <button
              type="button"
              @click="editingExp.is_visible = editingExp.is_visible === false ? true : false"
              :class="['relative inline-flex h-7 w-12 items-center rounded-full transition-colors focus:outline-none', editingExp.is_visible !== false ? 'bg-emerald-500' : 'bg-slate-300']"
            >
              <span :class="['inline-block h-5 w-5 transform rounded-full bg-white shadow transition-transform duration-200', editingExp.is_visible !== false ? 'translate-x-6' : 'translate-x-1']"></span>
            </button>
          </div>
        </div>
        <div class="p-4 border-t border-slate-200 flex justify-end gap-3 bg-slate-50">
          <button @click="showExpModal = false" class="py-2 px-4 border border-slate-300 rounded-md text-sm font-medium text-slate-700 hover:bg-white">ยกเลิก</button>
          <button @click="saveExp" :disabled="savingExp" class="py-2 px-4 bg-blue-600 rounded-md text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
            {{ savingExp ? 'กำลังบันทึก...' : 'บันทึกข้อมูล' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Education Modal -->
    <div v-if="showEduModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
        <div class="p-4 border-b border-slate-200 flex justify-between items-center">
          <h3 class="text-lg font-bold">{{ editingEdu.id ? 'แก้ไขประวัติการศึกษา' : 'เพิ่มประวัติการศึกษา' }}</h3>
          <button @click="showEduModal = false" class="text-slate-500 hover:text-slate-700">ปิด</button>
        </div>
        <div class="p-6 overflow-y-auto space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700">วุฒิการศึกษา</label>
            <input type="text" v-model="editingEdu.degree" required class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">สถาบัน</label>
            <input type="text" v-model="editingEdu.school" required class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">ปีที่สำเร็จการศึกษา</label>
            <input type="text" v-model="editingEdu.year" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">รายละเอียดเพิ่มเติม (สาขา/เอก)</label>
            <textarea rows="3" v-model="editingEdu.description" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
          </div>
          <!-- Visibility toggle -->
          <div :class="['flex items-center justify-between p-3.5 rounded-xl border transition-colors', editingEdu.is_visible !== false ? 'bg-emerald-50 border-emerald-200' : 'bg-slate-100 border-slate-300']">
            <div>
              <p class="text-sm font-semibold text-slate-800">การมองเห็น</p>
              <p :class="['text-xs mt-0.5', editingEdu.is_visible !== false ? 'text-emerald-700' : 'text-slate-500']">
                {{ editingEdu.is_visible !== false ? '✅ แสดงในหน้าประวัติ' : '🙈 ซ่อน ไม่แสดงแก่ผู้เข้าชม' }}
              </p>
            </div>
            <button
              type="button"
              @click="editingEdu.is_visible = editingEdu.is_visible === false ? true : false"
              :class="['relative inline-flex h-7 w-12 items-center rounded-full transition-colors focus:outline-none', editingEdu.is_visible !== false ? 'bg-emerald-500' : 'bg-slate-300']"
            >
              <span :class="['inline-block h-5 w-5 transform rounded-full bg-white shadow transition-transform duration-200', editingEdu.is_visible !== false ? 'translate-x-6' : 'translate-x-1']"></span>
            </button>
          </div>
        </div>
        <div class="p-4 border-t border-slate-200 flex justify-end gap-3 bg-slate-50">
          <button @click="showEduModal = false" class="py-2 px-4 border border-slate-300 rounded-md text-sm font-medium text-slate-700 hover:bg-white">ยกเลิก</button>
          <button @click="saveEdu" :disabled="savingEdu" class="py-2 px-4 bg-blue-600 rounded-md text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
            {{ savingEdu ? 'กำลังบันทึก...' : 'บันทึกข้อมูล' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Banner Modal -->
    <div v-if="showBannerModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
        <div class="p-4 border-b border-slate-200 flex justify-between items-center">
          <h3 class="text-lg font-bold">{{ editingBanner.id ? 'แก้ไขแบนเนอร์' : 'เพิ่มแบนเนอร์' }}</h3>
          <button @click="showBannerModal = false" class="text-slate-500 hover:text-slate-700">ปิด</button>
        </div>
        <div class="p-6 overflow-y-auto space-y-4">

          <!-- Inline size hint -->
          <div class="text-xs px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-slate-600">
            <span class="font-semibold">ขนาดที่แนะนำ:</span>
            อัตราส่วน <strong>16:9</strong> · รูป
            <strong>1920×1080</strong> &lt; 2 MB · วิดีโอ MP4
            <strong>1280×720</strong> ความยาว 5–15 วินาที &lt; 30 MB
          </div>

          <!-- Media Type -->
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1">ประเภทสื่อ</label>
            <div class="grid grid-cols-2 gap-2">
              <label class="flex items-center gap-2 p-2.5 border rounded-lg cursor-pointer transition-colors text-sm" :class="editingBanner.media_type === 'image' ? 'border-blue-500 bg-blue-50' : 'border-slate-200 hover:bg-slate-50'">
                <input type="radio" v-model="editingBanner.media_type" value="image" class="h-4 w-4 text-blue-600" />
                <span class="font-medium text-slate-900">🖼️ รูปภาพ</span>
              </label>
              <label class="flex items-center gap-2 p-2.5 border rounded-lg cursor-pointer transition-colors text-sm" :class="editingBanner.media_type === 'video' ? 'border-blue-500 bg-blue-50' : 'border-slate-200 hover:bg-slate-50'">
                <input type="radio" v-model="editingBanner.media_type" value="video" class="h-4 w-4 text-blue-600" />
                <span class="font-medium text-slate-900">🎬 วิดีโอ MP4</span>
              </label>
              <label class="flex items-center gap-2 p-2.5 border rounded-lg cursor-pointer transition-colors text-sm" :class="editingBanner.media_type === 'google_slide' ? 'border-blue-500 bg-blue-50' : 'border-slate-200 hover:bg-slate-50'">
                <input type="radio" v-model="editingBanner.media_type" value="google_slide" class="h-4 w-4 text-blue-600" />
                <span class="font-medium text-slate-900">📊 Google Slides</span>
              </label>
              <label class="flex items-center gap-2 p-2.5 border rounded-lg cursor-pointer transition-colors text-sm" :class="editingBanner.media_type === 'canva' ? 'border-blue-500 bg-blue-50' : 'border-slate-200 hover:bg-slate-50'">
                <input type="radio" v-model="editingBanner.media_type" value="canva" class="h-4 w-4 text-blue-600" />
                <span class="font-medium text-slate-900">🎨 Canva</span>
              </label>
            </div>
          </div>

          <!-- Preview -->
          <div v-if="editingBanner.media_url" class="relative bg-slate-100 rounded-lg overflow-hidden border border-slate-200" style="aspect-ratio: 16/9;">
            <img v-if="editingBanner.media_type === 'image'" :src="editingBanner.media_url" class="w-full h-full object-cover" :style="{ objectPosition: editingBanner.object_position || 'center' }" />
            <video v-else-if="editingBanner.media_type === 'video'" :src="editingBanner.media_url" class="w-full h-full object-cover" :style="{ objectPosition: editingBanner.object_position || 'center' }" muted autoplay loop playsinline></video>
            <iframe v-else-if="editingBanner.media_type === 'google_slide' || editingBanner.media_type === 'canva'" :src="normalizeEmbedUrl(editingBanner.media_url, editingBanner.media_type)" class="w-full h-full" frameborder="0" allow="autoplay; fullscreen"></iframe>
            <button @click="editingBanner.media_url = ''; bannerFile = null" class="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1.5 hover:bg-red-600 shadow">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
          </div>

          <!-- IMAGE: cropper button -->
          <div v-if="editingBanner.media_type === 'image'">
            <label class="block text-sm font-medium text-slate-700 mb-1">รูปภาพ (ครอบสัดส่วน 16:9)</label>
            <label class="cursor-pointer inline-flex items-center gap-2 py-2 px-4 border border-slate-300 shadow-sm text-sm font-medium rounded-md text-slate-700 bg-white hover:bg-slate-50 transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14M14 10h.01"/></svg>
              {{ editingBanner.media_url ? 'เปลี่ยนภาพ + ครอบใหม่' : 'เลือกภาพ + ครอบ' }}
              <input type="file" class="hidden" accept="image/*" @change="onBannerImageSelect" />
            </label>
            <p class="text-xs text-slate-500 mt-1">📐 จะมีกรอบครอบ 16:9 ให้เลือกพื้นที่แสดง</p>
          </div>

          <!-- VIDEO: file + position -->
          <div v-else-if="editingBanner.media_type === 'video'">
            <label class="block text-sm font-medium text-slate-700 mb-1">วิดีโอ MP4</label>
            <input type="file" accept="video/mp4,video/*" @change="onBannerFileSelect"
              class="block w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" />
            <p v-if="bannerFile" class="text-xs text-slate-500 mt-1">เลือก: {{ bannerFile.name }} ({{ (bannerFile.size / 1024 / 1024).toFixed(2) }} MB)</p>

            <!-- Object position selector for video -->
            <div class="mt-3 p-3 bg-slate-50 border border-slate-200 rounded-lg">
              <label class="block text-xs font-semibold text-slate-700 mb-2">📍 ตำแหน่งครอบเฟรม 16:9 (วิดีโอจะถูกครอบให้พอดีกับกรอบ)</label>
              <div class="grid grid-cols-3 gap-2">
                <label v-for="pos in ['top', 'center', 'bottom']" :key="pos"
                  class="flex flex-col items-center justify-center p-2 border rounded cursor-pointer text-xs font-medium transition-colors"
                  :class="editingBanner.object_position === pos ? 'border-blue-500 bg-blue-50 text-blue-700' : 'border-slate-200 bg-white hover:bg-slate-100 text-slate-600'">
                  <input type="radio" v-model="editingBanner.object_position" :value="pos" class="hidden" />
                  <span>{{ pos === 'top' ? '⬆️ บน' : pos === 'center' ? '⏺️ กลาง' : '⬇️ ล่าง' }}</span>
                </label>
              </div>
            </div>
          </div>

          <!-- EMBED: URL input -->
          <div v-else-if="editingBanner.media_type === 'google_slide' || editingBanner.media_type === 'canva'">
            <label class="block text-sm font-medium text-slate-700 mb-1">
              URL หรือโค้ด iframe ของ {{ editingBanner.media_type === 'google_slide' ? 'Google Slides' : 'Canva' }}
            </label>
            <textarea rows="3" v-model="editingBanner.media_url"
              :placeholder="editingBanner.media_type === 'google_slide'
                ? 'วาง URL หรือ &lt;iframe src=&quot;...&quot;&gt; ที่ได้จากการ Publish to web'
                : 'วาง URL หรือ &lt;iframe&gt; embed ที่ได้จาก Canva (Share → Embed)'"
              class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm font-mono"
            ></textarea>
            <div v-if="editingBanner.media_type === 'google_slide'" class="text-xs text-slate-500 mt-2 space-y-1">
              <p>📝 <strong>วิธีนำมา:</strong> Google Slides → File → Share → Publish to web → Embed → คัดลอกโค้ด หรือ URL</p>
              <p>✨ ระบบจะเพิ่ม <code class="bg-slate-100 px-1 rounded">start=true&loop=true&delayms=4000</code> ให้อัตโนมัติ</p>
            </div>
            <div v-else class="text-xs text-slate-500 mt-2 space-y-1">
              <p>📝 <strong>วิธีนำมา:</strong> Canva → Share → More → Embed → คัดลอกโค้ด</p>
              <p>✨ Canva จะเล่นอัตโนมัติเมื่ออยู่ในโหมด embed</p>
            </div>
          </div>

          <!-- Title / caption / link -->
          <div class="border-t border-slate-100 pt-4">
            <label class="block text-sm font-medium text-slate-700">หัวข้อ (แสดงทับสไลด์)</label>
            <input type="text" v-model="editingBanner.title" placeholder="ข่าวสารหรือกิจกรรมสำคัญ" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">คำอธิบายสั้น</label>
            <textarea rows="2" v-model="editingBanner.caption" class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">ลิงก์ปุ่ม "อ่านต่อ" (ไม่บังคับ)</label>
            <input type="text" v-model="editingBanner.link_url" placeholder="https://..." class="mt-1 block w-full border border-slate-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>

          <!-- Pin & Visibility -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <label class="flex items-center gap-3 p-3 border rounded-lg cursor-pointer transition-colors"
              :class="editingBanner.is_pinned ? 'border-amber-400 bg-amber-50' : 'border-slate-200 hover:bg-slate-50'">
              <input type="checkbox" v-model="editingBanner.is_pinned" class="h-4 w-4 text-amber-600 focus:ring-amber-500" />
              <div>
                <div class="text-sm font-medium text-slate-900 flex items-center gap-1.5">
                  <svg class="w-4 h-4 text-amber-500" fill="currentColor" viewBox="0 0 20 20"><path d="M10 2a1 1 0 011 1v1.586l3.707 3.707A1 1 0 0115 9v3a1 1 0 01-1 1h-3v4a1 1 0 11-2 0v-4H6a1 1 0 01-1-1V9a1 1 0 01.293-.707L9 4.586V3a1 1 0 011-1z"/></svg>
                  ตรึงไว้บนสุด
                </div>
                <div class="text-xs text-slate-500">แสดงก่อนเสมอ ไม่ขึ้นกับลำดับ</div>
              </div>
            </label>

            <label class="flex items-center gap-3 p-3 border rounded-lg cursor-pointer transition-colors"
              :class="editingBanner.is_visible ? 'border-emerald-400 bg-emerald-50' : 'border-slate-200 hover:bg-slate-50'">
              <input type="checkbox" v-model="editingBanner.is_visible" class="h-4 w-4 text-emerald-600 focus:ring-emerald-500" />
              <div>
                <div class="text-sm font-medium text-slate-900 flex items-center gap-1.5">
                  <svg class="w-4 h-4 text-emerald-500" fill="currentColor" viewBox="0 0 20 20"><path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/><path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/></svg>
                  แสดงในหน้าเว็บ
                </div>
                <div class="text-xs text-slate-500">ถ้าซ่อน จะไม่แสดงในสไลด์โชว์</div>
              </div>
            </label>
          </div>
        </div>
        <div class="p-4 border-t border-slate-200 flex justify-end gap-3 bg-slate-50">
          <button @click="showBannerModal = false" class="py-2 px-4 border border-slate-300 rounded-md text-sm font-medium text-slate-700 hover:bg-white">ยกเลิก</button>
          <button @click="saveBanner" :disabled="savingBanner" class="py-2 px-4 bg-blue-600 rounded-md text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
            <span v-if="uploadingBanner">กำลังอัปโหลด...</span>
            <span v-else-if="savingBanner">กำลังบันทึก...</span>
            <span v-else>บันทึกแบนเนอร์</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.solo-notice-enter-active, .solo-notice-leave-active { transition: all 0.3s ease; overflow: hidden; }
.solo-notice-enter-from, .solo-notice-leave-to { opacity: 0; max-height: 0; margin-top: 0; }
.solo-notice-enter-to, .solo-notice-leave-from { opacity: 1; max-height: 80px; }
</style>
