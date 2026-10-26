-- ============================================================
--  TLC Academy — Migration 02: حاوية تخزين صور الكورسات
--  شغّله في: Supabase → SQL Editor → New query → Run
-- ============================================================

-- 1) إنشاء حاوية عامة لصور الكورسات (القراءة متاحة للجميع عبر الرابط العام)
insert into storage.buckets (id, name, public)
values ('course-images', 'course-images', true)
on conflict (id) do nothing;

-- 2) صلاحيات الرفع/التعديل/الحذف للأدمن (مستخدم مسجّل دخول) داخل هذه الحاوية فقط
drop policy if exists "admin upload course images" on storage.objects;
create policy "admin upload course images"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'course-images');

drop policy if exists "admin update course images" on storage.objects;
create policy "admin update course images"
  on storage.objects for update to authenticated
  using (bucket_id = 'course-images')
  with check (bucket_id = 'course-images');

drop policy if exists "admin delete course images" on storage.objects;
create policy "admin delete course images"
  on storage.objects for delete to authenticated
  using (bucket_id = 'course-images');

-- 3) قراءة عامة لمحتوى الحاوية (احتياطياً؛ الحاوية عامة أصلاً)
drop policy if exists "public read course images" on storage.objects;
create policy "public read course images"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'course-images');
