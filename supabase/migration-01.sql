-- ============================================================
--  TLC Academy — Migration 01: إضافة عمودَي المدينة والنشرة البريدية
--  شغّله في: Supabase → SQL Editor → New query → Run
--  آمن للتكرار (يتجاهل العمود إن كان موجوداً).
-- ============================================================

alter table public.registrations
  add column if not exists city text;

alter table public.registrations
  add column if not exists newsletter_opt boolean not null default false;
