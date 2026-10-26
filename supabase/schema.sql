-- ============================================================
--  TLC Academy — Supabase schema (registrations + courses)
--  شغّل هذا الملف مرة واحدة في: Supabase Dashboard → SQL Editor → New query → Run
-- ============================================================

-- ========== 1) جدول المسجّلين (CRM) ==========
create table if not exists public.registrations (
  id             uuid primary key default gen_random_uuid(),
  created_at     timestamptz not null default now(),
  course_slug    text,
  course_title   text,
  full_name      text not null,
  email          text not null,
  phone          text not null,
  country        text,
  city           text,
  newsletter_opt boolean not null default false,
  email_verified boolean not null default false,
  source         text default 'website',
  notes          text
);

create index if not exists registrations_created_at_idx on public.registrations (created_at desc);
create index if not exists registrations_email_idx       on public.registrations (email);

alter table public.registrations enable row level security;

-- الزائر (المفتاح العام) يستطيع "الإضافة فقط" — لا يستطيع قراءة بيانات غيره
drop policy if exists "anon can insert registrations" on public.registrations;
create policy "anon can insert registrations"
  on public.registrations for insert
  to anon, authenticated
  with check (true);

-- الأدمن (مستخدم مسجّل دخول) يقرأ كل البيانات
drop policy if exists "authenticated can read registrations" on public.registrations;
create policy "authenticated can read registrations"
  on public.registrations for select
  to authenticated
  using (true);

-- الأدمن يستطيع الحذف
drop policy if exists "authenticated can delete registrations" on public.registrations;
create policy "authenticated can delete registrations"
  on public.registrations for delete
  to authenticated
  using (true);


-- ========== 2) جدول الكورسات ==========
create table if not exists public.courses (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  slug         text unique not null,
  title        text not null,
  level        text,                 -- شارة المستوى: مبتدئ / عملي / شامل ...
  description  text,
  image_url    text,                 -- مثال: assets/tlc3.jpeg
  page_url     text,                 -- مثال: course-start.html
  is_featured  boolean not null default false,  -- البطاقة الكبيرة بعرض كامل
  is_visible   boolean not null default true,   -- الإظهار/الإخفاء من الرئيسية
  sort_order   int     not null default 0       -- الترتيب (الأصغر يظهر أولاً)
);

create index if not exists courses_sort_idx on public.courses (sort_order asc);

alter table public.courses enable row level security;

-- الجمهور يقرأ الكورسات الظاهرة فقط؛ الأدمن يقرأ الكل (حتى المخفية)
drop policy if exists "public can read visible courses" on public.courses;
create policy "public can read visible courses"
  on public.courses for select
  to anon, authenticated
  using ( is_visible = true or (select auth.role()) = 'authenticated' );

-- الأدمن يضيف/يعدّل/يحذف
drop policy if exists "authenticated can manage courses" on public.courses;
create policy "authenticated can manage courses"
  on public.courses for all
  to authenticated
  using (true)
  with check (true);

-- تحديث updated_at تلقائياً عند أي تعديل
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists courses_set_updated_at on public.courses;
create trigger courses_set_updated_at
  before update on public.courses
  for each row execute function public.set_updated_at();


-- ========== 3) تعبئة الكورسات الحالية ==========
insert into public.courses (slug, title, level, description, image_url, page_url, is_featured, is_visible, sort_order)
values
  (
    'comprehensive',
    'الكورس الشامل للتجارة مع الصين',
    'شامل',
    'افهم رحلة الاستيراد خطوة بخطوة؛ من تقييم المشروع واختيار المنتج والمورد، إلى مقارنة الأسعار وفحص الجودة وحساب التكلفة والتسعير، وصولًا إلى الشحن والتخليص وتنفيذ أول طلبية.',
    'assets/tlc4.png',
    'course-comprehensive.html',
    true,  true, 1
  ),
  (
    'start',
    'كيف تبدأ مشروعك من الصين؟',
    'مبتدئ',
    'عندك فكرة مشروع ومش عارف من وين تبدأ؟ تعرّف على أساسيات اختيار المنتج ودراسة السوق، وكيف تقيّم فكرتك قبل اتخاذ أول خطوة في الشراء من الصين.',
    'assets/tlc3.jpeg',
    'course-start.html',
    false, true, 2
  ),
  (
    'sites',
    'كيف تشتري من المواقع الصينية؟',
    'عملي',
    'تعرّف على خطوات البحث عن المنتجات والموردين في المواقع الصينية، وقراءة معلومات المنتج والعرض، والتواصل مع المورد ومقارنة الخيارات قبل تأكيد الطلب.',
    'assets/tlc1.jpeg',
    'course-sites.html',
    false, true, 3
  )
on conflict (slug) do nothing;
