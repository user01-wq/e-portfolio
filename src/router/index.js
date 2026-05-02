import { createRouter, createWebHashHistory } from 'vue-router'
import { supabase } from '../lib/supabase'
import DefaultLayout from '../layouts/DefaultLayout.vue'

const router = createRouter({
  history: createWebHashHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: DefaultLayout,
      children: [
        {
          path: '',
          name: 'home',
          component: () => import('../views/Home.vue')
        },
        {
          path: 'resume',
          name: 'resume',
          component: () => import('../views/Resume.vue')
        },
        {
          path: 'projects',
          name: 'projects',
          component: () => import('../views/Projects.vue')
        },
        {
          path: 'contact',
          name: 'contact',
          component: () => import('../views/Contact.vue')
        }
      ]
    },
    {
      path: '/admin/login',
      name: 'login',
      component: () => import('../views/admin/Login.vue')
    },
    {
      path: '/admin',
      component: () => import('../layouts/AdminLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'dashboard',
          component: () => import('../views/admin/Dashboard.vue')
        }
      ]
    }
  ]
})

// Navigation Guard for Admin Routes
router.beforeEach(async (to, from, next) => {
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  
  if (requiresAuth) {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      next({ name: 'login' })
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
