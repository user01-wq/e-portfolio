# 🎓 E-Portfolio สำหรับครู

แฟ้มสะสมผลงานวิชาชีพออนไลน์ สำหรับครูและบุคลากรทางการศึกษา  
สร้างด้วย **Vue 3 + Vite + Tailwind CSS + Supabase**

---

## ✨ ฟีเจอร์หลัก

| ฟีเจอร์ | รายละเอียด |
|---------|-----------|
| 🖼️ แบนเนอร์สไลด์โชว์ | รูปภาพ / วิดีโอ / Google Slides / Canva · 4 เอฟเฟกต์ (Fade, Slide, Zoom, Flip) + สุ่ม · Solo Mode |
| 👤 โปรไฟล์ | ชื่อ / ทักทาย / bio (rich text) / avatar / social links |
| 📋 ประวัติ | ประสบการณ์ทำงาน + ประวัติการศึกษา · ลากเพื่อเรียงลำดับ (drag & drop) |
| 📦 คลังสื่อ | อัปโหลดรูป / วิดีโอ / ไฟล์ / embed / HTML code |
| ✉️ ติดต่อ | ฟอร์มสาธารณะพร้อม bot protection · admin อ่านได้อย่างเดียว |
| 🎨 ธีม | 10 ธีม (dark 6 + light 4) · Mourning Mode |
| ⚙️ Admin Panel | จัดการทุกอย่างผ่าน Dashboard · ไม่ต้องแตะโค้ด |

---

## 🚀 วิธีติดตั้ง (สำหรับคนที่ Fork)

### ขั้นตอนที่ 1 — Fork & Clone

```bash
# Fork บน GitHub ก่อน แล้ว clone repo ของคุณ
git clone https://github.com/<your-username>/e-portfolio.git
cd e-portfolio
npm install
```

---

### ขั้นตอนที่ 2 — สร้าง Supabase Project

1. ไปที่ [supabase.com](https://supabase.com) → **New Project**
2. ตั้งชื่อโปรเจกต์ เลือก Region ใกล้บ้าน (เช่น Singapore)
3. รอประมาณ 1 นาทีให้โปรเจกต์พร้อม

---

### ขั้นตอนที่ 3 — รัน Migration (สร้างตาราง)

1. ใน Supabase Dashboard → เมนู **SQL Editor**
2. คลิก **New Query**
3. เปิดไฟล์ `supabase/setup.sql` ในโปรเจกต์นี้
4. **คัดลอกทั้งหมด** แล้ว **วาง** ใน SQL Editor
5. กด **Run** (Ctrl+Enter)

> ✅ ควรได้ข้อความ "Success. No rows returned"

---

### ขั้นตอนที่ 4 — ตั้งค่า Environment Variables

```bash
# คัดลอกไฟล์ตัวอย่าง
cp .env.example .env.local
```

แล้วแก้ไขค่าใน `.env.local`:

```env
VITE_SUPABASE_URL=https://xxxxxxxxxxxxxxxxxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**หาค่าเหล่านี้ได้ที่:** Supabase Dashboard → **Project Settings** → **API**
- `Project URL` → ใส่ใน `VITE_SUPABASE_URL`
- `anon public` key → ใส่ใน `VITE_SUPABASE_ANON_KEY`

---

### ขั้นตอนที่ 5 — สร้าง Admin User

เลือกทำแบบใดแบบหนึ่ง:

**วิธี A — ผ่าน Supabase Dashboard (ง่ายที่สุด ไม่ต้องรันอะไร)**
1. Supabase Dashboard → เมนู **Authentication** → **Users**
2. กด **Add User** → ใส่อีเมลและรหัสผ่าน → **Create User**

**วิธี B — ผ่าน Script (รันบนเครื่องตัวเอง)**

> ต้องมี Node.js ติดตั้งบนเครื่อง และต้องทำขั้นตอนที่ 4 (.env.local) ก่อน

```bash
# เปิด Terminal แล้ว cd เข้าโฟลเดอร์โปรเจกต์
cd e-portfolio
node create-admin.mjs
# สคริปต์จะถามอีเมลและรหัสผ่าน
```

*(รันครั้งเดียวพอ — ไม่ต้องรันบน Vercel หรือ server)*

---

### ขั้นตอนที่ 6 — รันโปรเจกต์

```bash
npm run dev
```

เปิด [http://localhost:5173](http://localhost:5173)  
เข้าหน้า Admin ที่ [http://localhost:5173/admin/login](http://localhost:5173/admin/login)

---

## ▲ Deploy บน Vercel (แนะนำสำหรับผู้ที่ Fork)

วิธีนี้ **ง่ายที่สุด** — ไม่ต้องมี server เอง ไม่ต้องใช้ Docker

### ขั้นตอนเดียว: Import จาก GitHub

1. ไปที่ [vercel.com/new](https://vercel.com/new) → **Import Git Repository**
2. เลือก repo ที่ Fork มา
3. Vercel จะ detect เป็น **Vite** อัตโนมัติ (ไม่ต้องตั้งค่า build)
4. เปิด **Environment Variables** แล้วเพิ่ม 2 ค่า:

   | Key | Value |
   |-----|-------|
   | `VITE_SUPABASE_URL` | `https://xxxx.supabase.co` |
   | `VITE_SUPABASE_ANON_KEY` | `eyJhbG...` |

5. กด **Deploy** — รอ ~1 นาที ✅

> **หา URL + Key ได้ที่:** Supabase Dashboard → Project Settings → API

### อัปเดตเว็บเมื่อแก้โค้ด

Vercel **auto-deploy** ทุกครั้งที่ `git push` — ไม่ต้องทำอะไรเพิ่ม

---

## 🐳 รันด้วย Docker (ตัวเลือก)

```bash
# แก้ค่าใน docker-compose.yml ก่อน (VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY)
docker compose up --build
```

เปิด [http://localhost:8080](http://localhost:8080)

> **หมายเหตุ:** Docker ใช้แค่รัน Nginx serve static files  
> การเรียก Supabase API ทำจาก browser ตรงไปที่ supabase.com — ไม่ผ่าน container

---

## 📁 โครงสร้างโปรเจกต์

```
src/
├── views/
│   ├── Home.vue          — หน้าแรก (banner + profile + projects)
│   ├── Resume.vue        — ประสบการณ์ + การศึกษา
│   ├── Projects.vue      — คลังสื่อการสอน
│   ├── Contact.vue       — ฟอร์มติดต่อ
│   └── admin/
│       ├── Dashboard.vue — Admin Panel ทั้งหมด
│       └── Login.vue
├── layouts/
│   ├── DefaultLayout.vue — Navbar + Footer สำหรับหน้า public
│   └── AdminLayout.vue   — Sidebar สำหรับ admin
├── components/
│   ├── ProjectCard.vue
│   └── SiteFooter.vue
├── composables/
│   └── useTheme.js       — Global theme state
└── lib/
    └── supabase.js       — Supabase client

supabase/
├── setup.sql             — ⭐ All-in-one migration (ใช้ตอน Fork ใหม่)
└── migrations/           — Migration แยกชิ้น (สำหรับ Supabase CLI)
```

---

## 🔄 อัปเดต Migration (สำหรับผู้ใช้เดิมที่มีข้อมูลอยู่แล้ว)

หากคุณใช้โปรเจกต์นี้มาก่อนแล้ว และต้องการอัปเดตให้รองรับฟีเจอร์ใหม่  
ให้รัน migration เพิ่มเติมตามลำดับใน SQL Editor:

```
supabase/migrations/20260502000000_sort_order_visibility.sql
supabase/migrations/20260502000100_contact_messages.sql
supabase/migrations/20260502000200_profile_social_nav.sql
supabase/migrations/20260502000300_banner_effects.sql
```

---

## 🛠️ Tech Stack

- [Vue 3](https://vuejs.org/) + [Vite](https://vitejs.dev/)
- [Tailwind CSS v4](https://tailwindcss.com/)
- [Supabase](https://supabase.com/) (Database + Auth + Storage)
- [Vue Router](https://router.vuejs.org/)
- [vue-advanced-cropper](https://advanced-cropper.github.io/vue-advanced-cropper/)
- [@vueup/vue-quill](https://vueup.github.io/vue-quill/) (Rich text editor)

---

## 📄 License

MIT — ใช้ได้อย่างอิสระ ไม่ต้องถามอนุญาต
