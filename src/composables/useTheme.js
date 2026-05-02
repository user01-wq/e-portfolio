import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

// Global reactive state — shared across all components that call useTheme()
const currentTheme      = ref('ocean')
const siteName          = ref('KruPortfolio')
const logoUrl           = ref('')
const footerText        = ref('')
const showProfile       = ref(true)
const mourningMode      = ref(false)
const mourningEndDate   = ref(null)   // 'YYYY-MM-DD' or null
const portfolioBtnText  = ref('คลังสื่อการสอน')  // nav link label + homepage button
const portfolioTitle    = ref('')                  // Projects page h1
const portfolioSubtitle = ref('')                  // Projects page subtitle
const navVisibility     = ref({ resume: true, projects: true, contact: true })
const loadingTheme      = ref(true)

export function useTheme() {
  // Auto-expire: mourning is active when flag is on AND end date hasn't passed
  const isMourning = computed(() => {
    if (!mourningMode.value) return false
    if (!mourningEndDate.value) return true          // no end date → stay on indefinitely
    const end = new Date(mourningEndDate.value)
    end.setHours(23, 59, 59, 999)                    // include the full end day
    return new Date() <= end
  })

  const loadTheme = async () => {
    try {
      loadingTheme.value = true
      const { data } = await supabase
        .from('profiles')
        .select('theme, site_name, logo_url, footer_text, show_profile, mourning_mode, mourning_end_date, portfolio_btn_text, portfolio_title, portfolio_subtitle, nav_visibility')
        .limit(1)
        .single()

      if (data) {
        if (data.theme)     currentTheme.value     = data.theme
        if (data.site_name) siteName.value         = data.site_name
        logoUrl.value           = data.logo_url           || ''
        footerText.value        = data.footer_text         || ''
        showProfile.value       = data.show_profile        ?? true
        mourningMode.value      = data.mourning_mode       ?? false
        mourningEndDate.value   = data.mourning_end_date   || null
        portfolioBtnText.value  = data.portfolio_btn_text  || 'คลังสื่อการสอน'
        portfolioTitle.value    = data.portfolio_title     || ''
        portfolioSubtitle.value = data.portfolio_subtitle  || ''
        navVisibility.value     = {
          resume:   data.nav_visibility?.resume   ?? true,
          projects: data.nav_visibility?.projects ?? true,
          contact:  data.nav_visibility?.contact  ?? true,
        }
      }
    } catch (err) {
      console.error('Error loading theme:', err.message)
    } finally {
      loadingTheme.value = false
    }
  }

  return {
    currentTheme, siteName, logoUrl, footerText,
    showProfile, mourningMode, mourningEndDate, isMourning,
    portfolioBtnText, portfolioTitle, portfolioSubtitle,
    navVisibility,
    loadingTheme, loadTheme,
  }
}
