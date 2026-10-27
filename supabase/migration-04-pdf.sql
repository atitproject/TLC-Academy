-- ============================================================
--  TLC Academy — Migration 04: ملف PDF لكل كورس
--  شغّله في: Supabase → SQL Editor → New query → Run
-- ============================================================

-- 1) عمود رابط ملف الـPDF في جدول الكورسات
alter table public.courses
  add column if not exists pdf_url text;

-- 2) حاوية تخزين ملفات الكورسات (PDF)
insert into storage.buckets (id, name, public)
values ('course-pdfs', 'course-pdfs', true)
on conflict (id) do nothing;

-- 3) صلاحيات: الرفع/التعديل/الحذف للأدمن، والقراءة عبر الرابط للجميع
drop policy if exists "admin upload course pdfs" on storage.objects;
create policy "admin upload course pdfs"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'course-pdfs');

drop policy if exists "admin update course pdfs" on storage.objects;
create policy "admin update course pdfs"
  on storage.objects for update to authenticated
  using (bucket_id = 'course-pdfs')
  with check (bucket_id = 'course-pdfs');

drop policy if exists "admin delete course pdfs" on storage.objects;
create policy "admin delete course pdfs"
  on storage.objects for delete to authenticated
  using (bucket_id = 'course-pdfs');

drop policy if exists "public read course pdfs" on storage.objects;
create policy "public read course pdfs"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'course-pdfs');
