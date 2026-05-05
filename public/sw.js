// Service Worker — E-Portfolio PWA
const CACHE = 'e-portfolio-v1'

self.addEventListener('install', () => self.skipWaiting())
self.addEventListener('activate', (e) => e.waitUntil(clients.claim()))

self.addEventListener('fetch', (e) => {
  // ข้ามคำขอที่ไม่ใช่ GET และ Supabase API
  if (e.request.method !== 'GET') return
  if (e.request.url.includes('supabase.co')) return

  e.respondWith(
    fetch(e.request)
      .then((res) => {
        // cache เฉพาะ static assets (png, svg, js, css, font)
        if (/\.(png|svg|js|css|woff2?)(\?.*)?$/.test(e.request.url)) {
          const clone = res.clone()
          caches.open(CACHE).then((c) => c.put(e.request, clone))
        }
        return res
      })
      .catch(() => caches.match(e.request))
  )
})
