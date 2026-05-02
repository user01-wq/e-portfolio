<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../../lib/supabase'

const router = useRouter()
const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')

async function handleLogin() {
  try {
    loading.value = true
    errorMsg.value = ''
    
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })

    if (error) throw error
    
    if (data.user) {
      router.push('/admin')
    }
  } catch (error) {
    errorMsg.value = error.message === 'Invalid login credentials' 
      ? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' 
      : error.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen relative flex items-center justify-center overflow-hidden bg-slate-900">
    
    <!-- Animated Background Elements -->
    <div class="absolute inset-0 w-full h-full">
      <div class="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-blue-600/30 blur-[120px] animate-blob"></div>
      <div class="absolute top-[20%] right-[-10%] w-[50%] h-[50%] rounded-full bg-purple-600/30 blur-[120px] animate-blob animation-delay-2000"></div>
      <div class="absolute bottom-[-20%] left-[20%] w-[60%] h-[60%] rounded-full bg-emerald-500/20 blur-[120px] animate-blob animation-delay-4000"></div>
    </div>

    <!-- Login Container -->
    <div class="relative z-10 w-full max-w-md px-6 py-12">
      <!-- Logo or Icon -->
      <div class="flex justify-center mb-8 animate-fade-in-up">
        <div class="w-16 h-16 bg-white/10 backdrop-blur-md rounded-2xl flex items-center justify-center border border-white/20 shadow-[0_0_40px_rgba(59,130,246,0.3)]">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
          </svg>
        </div>
      </div>

      <!-- Glassmorphic Card -->
      <div class="bg-white/10 backdrop-blur-xl rounded-3xl p-8 border border-white/10 shadow-2xl animate-fade-in-up animation-delay-150">
        <h2 class="text-center text-3xl font-bold text-white mb-2 tracking-tight">
          เข้าสู่ระบบจัดการ
        </h2>
        <p class="text-center text-slate-300 text-sm mb-8">
          Teacher E-Portfolio Admin
        </p>

        <form class="space-y-6" @submit.prevent="handleLogin">
          
          <div class="space-y-1">
            <label for="email" class="block text-sm font-medium text-slate-200">อีเมล</label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <svg class="h-5 w-5 text-slate-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
                  <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
                </svg>
              </div>
              <input id="email" name="email" type="email" required v-model="email" 
                class="block w-full pl-10 pr-3 py-3 border border-white/10 rounded-xl leading-5 bg-white/5 text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 focus:bg-white/10 transition-all duration-300 sm:text-sm" 
                placeholder="admin@school.ac.th" />
            </div>
          </div>

          <div class="space-y-1">
            <label for="password" class="block text-sm font-medium text-slate-200">รหัสผ่าน</label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <svg class="h-5 w-5 text-slate-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd" />
                </svg>
              </div>
              <input id="password" name="password" type="password" required v-model="password" 
                class="block w-full pl-10 pr-3 py-3 border border-white/10 rounded-xl leading-5 bg-white/5 text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 focus:bg-white/10 transition-all duration-300 sm:text-sm" 
                placeholder="••••••••" />
            </div>
          </div>

          <!-- Error Message -->
          <div v-if="errorMsg" class="bg-red-500/10 border border-red-500/50 rounded-lg p-3 animate-shake">
            <p class="text-sm text-red-400 text-center">{{ errorMsg }}</p>
          </div>

          <div>
            <button type="submit" :disabled="loading" 
              class="group relative w-full flex justify-center py-3 px-4 border border-transparent rounded-xl text-sm font-bold text-white bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-500 hover:to-purple-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 focus:ring-offset-slate-900 overflow-hidden transition-all duration-300 transform hover:-translate-y-0.5 hover:shadow-[0_0_20px_rgba(59,130,246,0.5)] disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none">
              <span class="absolute inset-0 w-full h-full -mt-1 rounded-lg opacity-30 bg-gradient-to-b from-transparent via-transparent to-black"></span>
              <span class="relative flex items-center">
                <svg v-if="loading" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                {{ loading ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ' }}
              </span>
            </button>
          </div>
        </form>
      </div>

      <div class="text-center mt-8 animate-fade-in-up animation-delay-300">
        <router-link to="/" class="inline-flex items-center text-sm font-medium text-slate-400 hover:text-white transition-colors duration-200">
          <svg class="mr-2 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
          กลับไปหน้าเว็บไซต์หลัก
        </router-link>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes blob {
  0% { transform: translate(0px, 0px) scale(1); }
  33% { transform: translate(30px, -50px) scale(1.1); }
  66% { transform: translate(-20px, 20px) scale(0.9); }
  100% { transform: translate(0px, 0px) scale(1); }
}

@keyframes fade-in-up {
  0% { opacity: 0; transform: translateY(20px); }
  100% { opacity: 1; transform: translateY(0); }
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-4px); }
  20%, 40%, 60%, 80% { transform: translateX(4px); }
}

.animate-blob {
  animation: blob 7s infinite;
}

.animate-fade-in-up {
  animation: fade-in-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
  opacity: 0;
}

.animate-shake {
  animation: shake 0.5s cubic-bezier(.36,.07,.19,.97) both;
}

.animation-delay-150 {
  animation-delay: 150ms;
}

.animation-delay-300 {
  animation-delay: 300ms;
}

.animation-delay-2000 {
  animation-delay: 2s;
}

.animation-delay-4000 {
  animation-delay: 4s;
}
</style>
