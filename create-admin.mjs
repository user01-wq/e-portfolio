/**
 * สร้าง Admin User สำหรับ E-Portfolio
 * รันครั้งเดียวหลัง setup.sql เสร็จ
 *
 * วิธีใช้:
 *   node create-admin.mjs
 *
 * ต้องมีไฟล์ .env.local ที่มี VITE_SUPABASE_URL และ VITE_SUPABASE_ANON_KEY ก่อน
 */

import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'
import { createInterface } from 'readline'

// ── อ่าน .env.local ─────────────────────────────────────────
function loadEnv() {
  try {
    const raw = readFileSync('.env.local', 'utf8')
    const env = {}
    for (const line of raw.split('\n')) {
      const m = line.match(/^([^#=]+)=(.*)$/)
      if (m) env[m[1].trim()] = m[2].trim().replace(/^["']|["']$/g, '')
    }
    return env
  } catch {
    return {}
  }
}

// ── อ่าน input จาก terminal ─────────────────────────────────
function ask(rl, question) {
  return new Promise(resolve => rl.question(question, resolve))
}

// ── Main ─────────────────────────────────────────────────────
async function main() {
  const env = loadEnv()

  const supabaseUrl  = env.VITE_SUPABASE_URL  || process.env.VITE_SUPABASE_URL
  const supabaseKey  = env.VITE_SUPABASE_ANON_KEY || process.env.VITE_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseKey) {
    console.error('\n❌  ไม่พบ VITE_SUPABASE_URL หรือ VITE_SUPABASE_ANON_KEY')
    console.error('    กรุณาสร้างไฟล์ .env.local ก่อน (ดูตัวอย่างใน .env.example)\n')
    process.exit(1)
  }

  console.log('\n🎓  E-Portfolio — สร้าง Admin User')
  console.log('─'.repeat(40))
  console.log(`📡  Supabase: ${supabaseUrl}\n`)

  const rl = createInterface({ input: process.stdin, output: process.stdout })

  const email    = await ask(rl, '📧  อีเมล admin  : ')
  const password = await ask(rl, '🔑  รหัสผ่าน    : ')
  rl.close()

  if (!email || !password) {
    console.error('\n❌  กรุณากรอกอีเมลและรหัสผ่าน\n')
    process.exit(1)
  }
  if (password.length < 6) {
    console.error('\n❌  รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร\n')
    process.exit(1)
  }

  console.log('\n⏳  กำลังสร้าง user...')

  const supabase = createClient(supabaseUrl, supabaseKey)
  const { data, error } = await supabase.auth.signUp({ email, password })

  if (error) {
    console.error(`\n❌  สร้างไม่สำเร็จ: ${error.message}\n`)
    process.exit(1)
  }

  console.log(`\n✅  สร้าง admin สำเร็จ!`)
  console.log(`    อีเมล : ${data.user.email}`)
  console.log(`    ID    : ${data.user.id}`)

  // หาก Supabase Cloud เปิด Email Confirmation อยู่ แจ้งเตือน
  if (!data.session) {
    console.log('\n⚠️   Supabase ส่ง email ยืนยันไปแล้ว กรุณาเช็คกล่องจดหมายแล้วกดยืนยันก่อน login')
    console.log('    หรือไปปิด "Confirm email" ที่ Supabase Dashboard → Authentication → Providers → Email\n')
  } else {
    console.log('\n🚀  Login ได้เลยที่ /admin/login\n')
  }
}

main()
