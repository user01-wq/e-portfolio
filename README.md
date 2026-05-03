# 🎓 E-Portfolio สำหรับครู

แฟ้มสะสมผลงานวิชาชีพออนไลน์ สำหรับครูและบุคลากรทางการศึกษา  
**ไม่ต้องเขียนโค้ด · ไม่ต้องมี server · ใช้งานผ่านเว็บได้เลย**

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

## 🚀 วิธีติดตั้ง (ทำครั้งเดียว ใช้ได้ตลอด)

**ภาพรวม:**
```
1. Fork repo  →  2. สร้าง Supabase  →  3. สร้าง Admin  →  4. Deploy Vercel  →  5. ตั้ง Secrets
```

---

### 🎬 ก่อนเริ่ม — ดูวิดีโอสอนสมัคร GitHub และ Vercel

> ยังไม่มีบัญชี GitHub หรือ Vercel? ดูวิดีโอสอนได้ที่  
> 📺 **[youtube.com/@WinaiVibeCoding](https://www.youtube.com/@WinaiVibeCoding)**

---

### ขั้นตอนที่ 1 — Fork repo

1. ไปที่ **[github.com/user01-wq/e-portfolio](https://github.com/user01-wq/e-portfolio)**
2. กดปุ่ม **Fork** (มุมขวาบน)
3. กด **Create fork** — เสร็จแล้ว! repo จะอยู่ที่ `github.com/ชื่อของคุณ/e-portfolio`

---

### ขั้นตอนที่ 2 — สร้าง Supabase Project (ฐานข้อมูลฟรี)

1. ไปที่ [supabase.com](https://supabase.com) → สมัครฟรี → **New Project**
2. ตั้งชื่อโปรเจกต์ เลือก Region: **Southeast Asia (Singapore)**
3. รอ ~1 นาทีให้โปรเจกต์พร้อม
4. ไปที่เมนู **SQL Editor** → คลิก **New Query**
5. เปิดไฟล์ `supabase/setup.sql` ใน repo แล้ว **คัดลอกทั้งหมด**
6. **วาง** ใน SQL Editor → กด **Run** (หรือ Ctrl+Enter)

> ✅ ควรได้ข้อความ "Success. No rows returned"

---

### ขั้นตอนที่ 3 — สร้าง Admin User

1. Supabase Dashboard → เมนู **Authentication** → **Users**
2. กด **Add User** → **Create new user**
3. ใส่อีเมลและรหัสผ่านที่ต้องการ
4. ติ๊ก ✅ **Auto Confirm User** → กด **Create User**

---

### ขั้นตอนที่ 4 — Deploy บน Vercel (เผยแพร่เว็บ)

1. ไปที่ [vercel.com](https://vercel.com) → สมัครฟรีด้วย GitHub
2. กด **Add New Project** → **Import** repo `e-portfolio` ที่ Fork มา
3. เลื่อนลงหา **Environment Variables** → เพิ่ม 2 ค่า:

   | Key | Value (หาได้จาก Supabase → Project Settings → API) |
   |-----|-------|
   | `VITE_SUPABASE_URL` | `https://xxxx.supabase.co` (Project URL) |
   | `VITE_SUPABASE_ANON_KEY` | `eyJhbG...` (anon public key) |

4. กด **Deploy** — รอ ~1 นาที ✅
5. เว็บพร้อมใช้งานที่ URL ที่ Vercel ให้มา เช่น `my-portfolio.vercel.app`

> เข้าหน้า Admin ที่ `your-url.vercel.app/admin/login`

---

### ขั้นตอนที่ 5 — ตั้ง GitHub Secrets (ปลุก Supabase อัตโนมัติ)

Supabase free tier จะหยุดทำงานหากไม่มีคนเข้าใช้ 7 วัน — ขั้นตอนนี้ให้ระบบ ping อัตโนมัติทุก 3 วัน

1. ไปที่ GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. กด **New repository secret** → เพิ่ม 2 ตัว:

   | Name | Secret |
   |------|--------|
   | `VITE_SUPABASE_URL` | `https://xxxx.supabase.co` |
   | `VITE_SUPABASE_ANON_KEY` | `eyJhbG...` |

> ✅ หลังจากนี้ระบบจะปลุก Supabase ให้อัตโนมัติ ไม่ต้องทำอะไรเพิ่ม

---

## 📄 License

MIT — ใช้ได้อย่างอิสระ ไม่ต้องถามอนุญาต
