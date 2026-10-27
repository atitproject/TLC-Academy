/* ============================================================
   TLC Academy — Supabase client (frontend)
   المفتاح أدناه هو "المفتاح العام" (publishable) وآمن للنشر العلني.
   لا تضع المفتاح السري (secret) هنا أبداً.
   ============================================================ */
(function () {
  var SUPABASE_URL = 'https://xuggbedyeapxaytzixps.supabase.co';
  var SUPABASE_KEY = 'sb_publishable_-9HtCsowbvRe9_Ro9JMKKQ_bAulNrnh';

  window.TLC = window.TLC || {};
  window.TLC.supa = { url: SUPABASE_URL, key: SUPABASE_KEY };

  function headers(extra) {
    var h = { 'apikey': SUPABASE_KEY, 'Authorization': 'Bearer ' + SUPABASE_KEY };
    if (extra) for (var k in extra) h[k] = extra[k];
    return h;
  }

  // إضافة تسجيل جديد (الزائر يضيف فقط؛ نستخدم return=minimal حتى لا يحاول القراءة)
  window.TLC.insertRegistration = async function (row) {
    var res = await fetch(SUPABASE_URL + '/rest/v1/registrations', {
      method: 'POST',
      headers: headers({ 'Content-Type': 'application/json', 'Prefer': 'return=minimal' }),
      body: JSON.stringify([row])
    });
    if (!res.ok) {
      var msg = 'HTTP ' + res.status;
      try { var j = await res.json(); msg = j.message || msg; } catch (e) {}
      throw new Error(msg);
    }
    return true;
  };

  // جلب الكورسات الظاهرة مرتّبة حسب sort_order
  // (نحدّد الأعمدة صراحةً حتى لا يصل رابط الـPDF إلى الموقع العام)
  window.TLC.fetchCourses = async function () {
    var cols = 'slug,title,level,description,image_url,page_url,is_featured,is_visible,sort_order';
    var res = await fetch(SUPABASE_URL + '/rest/v1/courses?select=' + cols + '&order=sort_order.asc', {
      headers: headers()
    });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    return await res.json();
  };
})();
