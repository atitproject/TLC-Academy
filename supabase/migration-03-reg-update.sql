-- ============================================================
--  TLC Academy — Migration 03: السماح للأدمن بتعديل بيانات المسجّلين
--  شغّله في: Supabase → SQL Editor → New query → Run
-- ============================================================

drop policy if exists "authenticated can update registrations" on public.registrations;
create policy "authenticated can update registrations"
  on public.registrations for update
  to authenticated
  using (true)
  with check (true);
